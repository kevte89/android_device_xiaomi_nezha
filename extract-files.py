#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Copy the reviewed Nezha-309 allowlist, then generate draft vendor makefiles.

No adb/archive/network source, inherited fixup or source build is used.
The common module deliberately uses this device's separately reviewed list.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import xml.etree.ElementTree as ET
import sys

sys.dont_write_bytecode = True
DEVICE = Path(__file__).resolve().parent
ROOT = DEVICE.parents[2]
STOCK = Path('/home/kevte89/android/stock/nezha_a16_cn_309/super_extracted')
sys.path.insert(0, str(ROOT / 'tools/extract-utils'))
from extract_utils.main import ExtractUtils, ExtractUtilsModule
from extract_utils.module import ProprietaryFile
from extract_utils.fixups_lib import lib_fixup_vendorcompat, libs_proto_21_12
from extract_utils.fixups_lib import libs_clang_rt_ubsan, lib_fixup_remove_arch_suffix

namespace_imports = [
    'device/xiaomi/sm8850-common',
    'hardware/qcom-caf/sm8850',
    'hardware/xiaomi',
    'vendor/qcom/opensource/commonsys-intf/display',
    'vendor/xiaomi/sm8850-common',
]
BUILD_ALIASES = json.loads((DEVICE / 'stock-evidence/vendor-selection.json').read_text())['build_library_aliases']

def vendor_partition_alias(lib, partition, *args, **kwargs):
    return lib + '_vendor' if partition in ('vendor', 'odm') else None

# Build dependency aliases; separately pinned transforms cover reviewed ELF changes.
lib_fixups = {
    libs_clang_rt_ubsan: lib_fixup_remove_arch_suffix,
    tuple(BUILD_ALIASES): vendor_partition_alias,
    libs_proto_21_12: lib_fixup_vendorcompat,
}

module = ExtractUtilsModule(
    'nezha', 'xiaomi', blob_fixups={}, lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)
common_module = ExtractUtilsModule(
    'sm8850-common', 'xiaomi', device_rel_path='device/xiaomi/nezha',
    blob_fixups={}, lib_fixups=lib_fixups,
    namespace_imports=[p for p in namespace_imports if p != 'vendor/xiaomi/sm8850-common'] + [
        'vendor/qcom/opensource/dataservices',
        'hardware/qcom-caf/wlan',
        'vendor/qcom/opensource/commonsys/display',
        'vendor/xiaomi/nezha',
    ],
    skip_main_proprietary_file=True,
    proprietary_files=[ProprietaryFile(str(DEVICE / 'proprietary-files-common.txt'))],
)

def digest(p):
    h = hashlib.sha256()
    with p.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()

def reviewed_files():
    manifest = json.loads((DEVICE / 'stock-evidence/vendor-selection.json').read_text())
    if (manifest['stock'], manifest['android'], manifest['region']) != ('OS3.0.309.0.WPACNXM', '16', 'CN'):
        raise RuntimeError('Unexpected stock identity')
    # The lists must match the separately SHA-256-pinned selection exactly.
    for group, filename in [('device', 'proprietary-files.txt'), ('common', 'proprietary-files-common.txt')]:
        expected = {e['path']: e.get('output_sha1', e['sha1']) for e in manifest['files'] if e['group'] == group}
        destinations = {e['path']: e.get('output_path', e['path']) for e in manifest['files'] if e['group'] == group}
        actual = {}
        for line in (DEVICE / filename).read_text().splitlines():
            if not line.strip() or line.startswith('#'):
                continue
            spec, sha1 = line.split('|')
            path, *flags = spec.split(';')
            source_path, separator, output_path = path.partition(':')
            if (output_path if separator else source_path) != destinations.get(source_path):
                raise RuntimeError('Unreviewed destination: ' + path)
            path = source_path
            # Only metadata separately justified by inspected stock and build rules.
            if flags != manifest['build_metadata'].get(path, []):
                raise RuntimeError('Unreviewed list option: ' + line)
            if path in actual:
                raise RuntimeError('Alias or duplicate not reviewed: ' + path)
            actual[path] = sha1
        if actual != expected:
            raise RuntimeError('List differs from reviewed selection: ' + filename)
    return manifest

def apply_reviewed_transforms(destination, entry, manifest):
    for op in entry.get('transforms', []):
        if op['kind'] == 'xml_declaration':
            data = destination.read_bytes()
            if data.count(b'xml=version') != 1:
                raise RuntimeError('Unexpected XML precondition')
            data = data.replace(b'xml=version', b'xml version')
            ET.fromstring(data)
            destination.write_bytes(data)
        elif op['kind'] == 'qspa_default_import':
            data = destination.read_bytes()
            old = b'qspa_${ro.boot.vendor.qspa:-default}.rc'
            if data.count(old) != 1:
                raise RuntimeError('Unexpected QSPA import')
            destination.write_bytes(data.replace(old, b'qspa_default.rc'))
        elif op['kind'] == 'set_soname':
            tool = ROOT / manifest['transform_tool']['path']
            if digest(tool) != manifest['transform_tool']['sha256'] or op['value'] != destination.name:
                raise RuntimeError('Unreviewed SONAME/tool')
            subprocess.run([str(tool), '--set-soname', op['value'], str(destination)], check=True)
        elif op['kind'] == 'replace_needed':
            tool = ROOT / manifest['transform_tool']['path']
            if digest(tool) != manifest['transform_tool']['sha256']:
                raise RuntimeError('Reviewed patchelf changed')
            subprocess.run([str(tool), '--replace-needed', op['old'], op['new'], str(destination)], check=True)
        elif op['kind'] == 'add_needed':
            tool = ROOT / manifest['transform_tool']['path']
            if digest(tool) != manifest['transform_tool']['sha256']:
                raise RuntimeError('Reviewed patchelf changed')
            if op['value'] not in ('libaudioutils_shim.so', 'libbluetooth_audio_session_aidl_shim.so'):
                raise RuntimeError('Unreviewed shim')
            subprocess.run([str(tool), '--add-needed', op['value'], str(destination)], check=True)
        else:
            raise RuntimeError('Unreviewed transform')

def run(regenerate=False):
    manifest = reviewed_files()
    records = []
    for entry in manifest['files']:
        part, relative = entry['path'].split('/', 1)
        if part not in ('vendor', 'odm', 'product', 'system_ext', 'vendor_dlkm', 'system_dlkm') or '..' in Path(relative).parts:
            raise RuntimeError('Unapproved partition/path')
        source = STOCK / (part + '_a.fs') / relative
        if source.is_symlink() or not source.resolve().is_relative_to(STOCK / (part + '_a.fs')):
            raise RuntimeError('Source escapes verified partition: ' + str(source))
        tree = 'nezha' if entry['group'] == 'device' else 'sm8850-common'
        vendor = ROOT / 'vendor/xiaomi' / tree
        output_path = entry.get('output_path', entry['path'])
        if Path(output_path).is_absolute() or '..' in Path(output_path).parts or output_path.split('/', 1)[0] != part:
            raise RuntimeError('Unapproved output path: ' + output_path)
        destination = vendor / 'proprietary' / output_path
        if not destination.resolve().is_relative_to(vendor.resolve()):
            raise RuntimeError('Destination escapes vendor tree')
        expected_hash = entry.get('output_sha256', entry['sha256'])
        if regenerate:
            if not destination.is_file() or destination.is_symlink() or digest(destination) != expected_hash:
                raise RuntimeError('Missing or changed staged blob: ' + str(destination))
        else:
            if digest(source) != entry['sha256']:
                raise RuntimeError('Stock blob changed: ' + str(source))
            if destination.exists():
                if destination.is_symlink() or digest(destination) != expected_hash:
                    raise RuntimeError('Refusing to overwrite different blob: ' + str(destination))
            else:
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(source, destination)
                os.chmod(destination, int(entry['mode'], 8))
                apply_reviewed_transforms(destination, entry, manifest)
            if digest(destination) != expected_hash:
                raise RuntimeError('Copied blob hash mismatch: ' + str(destination))
        records.append({'path':str(destination.relative_to(ROOT)), 'source':str(source), 'sha256':expected_hash, 'source_sha256':entry['sha256'], 'transforms':entry.get('transforms', []), 'group':entry['group']})
    # Local extract-utils only emits makefiles here; it does not compile anything.
    sys.argv = [str(DEVICE / 'extract-files.py'), '--regenerate_makefiles']
    ExtractUtils(module, [common_module]).run()
    for group, tree in [('device', 'nezha'), ('common', 'sm8850-common')]:
        output = ROOT / 'vendor/xiaomi' / tree
        provenance = {'stock':manifest['stock'], 'android':'16', 'region':'CN', 'applied_blob_fixups':[{'path':e['path'], 'operations':e['transforms']} for e in records if e['group']==group and e['transforms']], 'files':[e for e in records if e['group']==group]}
        (output / 'stock-provenance.json').write_text(json.dumps(provenance, indent=2) + '\n')
    print('Verified stock-derived blobs:',len(records))
    print('Draft makefiles generated; pending fixups/dependencies remain in stock-evidence. No build performed.')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--regenerate_makefiles', action='store_true')
    args = parser.parse_args()
    run(regenerate=args.regenerate_makefiles)
