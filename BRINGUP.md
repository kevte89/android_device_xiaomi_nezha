# Nezha 309 bring-up status

Stock: OS3.0.309.0.WPACNXM, Android 16, CN only.
The real lineage_nezha-cp2a-userdebug bacon build was explicitly authorized and attempted on 2026-09-19. No flash has run.

Current detailed evidence is authoritative over earlier historical audit snapshots:
- `stock-evidence/uapi-resolution.tsv`: 9 missing permissible UAPI definitions; 3 IPA source candidates awaiting export/ABI resolution.
- `stock-evidence/vendor-missing-classification.tsv`: all 220 comparison paths; class counts 109/7/9/0/1/94. Missing comparison paths are not automatically Nezha errors.
- `stock-evidence/vendor-fixup-validation.tsv`: all 124 operations; 7 applied, 56 rejected/not required, 61 tinyxml2 ABI decisions open.
- `stock-evidence/vendor-list-option-classification.tsv`: all 69 cases classified; 9 SONAME fixes, 16 packaging destinations, 5 required dependencies applied, 38 not imported, 1 fingerprint loader blocker.
- `stock-evidence/vendor-static-validation.json`: 3096 stock-derived blobs (1374 device/1722 common), 15 transformed payloads, 1791 unique generated modules, no missing literal sources or broken selected symlinks. This does not evaluate the Soong graph.
- `stock-evidence/repository-ownership.json`: repository ownership and future publication boundaries; nothing published.

All source and resulting hashes and reviewed transformations are pinned in `stock-evidence/vendor-selection.json`. The extraction script reproduces only these transformations; setup validates the staged result and emits vendor descriptions without compiling. Already staged blobs were not re-extracted. Stock EcoInfoDynamic.json remains unchanged.

Kernel/DTB/DTBO/module provenance from the earlier completed pass remains valid. No shared source/core edits or foreign-device payload have been introduced. Device hardware integration and ABI questions still prevent build readiness.

## Real build continuation, 2026-09-19

Target: `lunch lineage_nezha-cp2a-userdebug`, `mka bacon -j8`, existing out reused.

Sequential fixes restricted to Nezha device and generated Xiaomi vendor metadata:
- `libtensorflowlite_c`: add MODULE_SUFFIX=_vendor and vendor/odm dependency alias. Myron/Common also separates this library from the platform module, using a renamed ELF; this port uses a build-only alias with the original installation stem and unchanged Nezha ELF.
- `libdng_sdk`: same build-only namespace separation; Myron uses a -myron renamed ELF. No Myron payload was copied.
- Common vendor namespace: import vendor/qcom/opensource/commonsys/display as in the existing Common extractor, resolving libdisplayconfig.system.qti.
- Regeneration verified all 3096 staged payload hashes. No extraction, clean, sync or core source patch.

Current first error (out/nezha-bringup/bacon-resume-display.log):
`vendor/xiaomi/sm8850-common/Android.bp:24116:1: "libwfdcommonutils" depends on undefined module "libheif".`

The Nezha system_ext/lib64/libwfdcommonutils.so ELF has DT_NEEDED libheif.so. The existing Myron/Common list also includes libwfdcommonutils.so. The platform provider was removed in frameworks/av commit baa3574157 (Remove libheif source directory). No libheif module definition was found in frameworks/av, external or hardware/lineage/compat. Restoring the platform provider would require changes outside the four authorized device/vendor trees. Stopped at this boundary; no dependency suppression, older-platform substitution or core patch. ROM build remains unsuccessful and ABI/runtime validation remains outstanding.

## Build continuation, 2026-09-20

Continued existing `lineage_nezha-cp2a-userdebug` build with `mka bacon -j8`,
without sync, clean, or downloads. Current log: `out/nezha-bringup/bacon-20260920.log`.
The previously staged platform libheif restoration is present.

Resolved the two AIDL version conflicts reported by `bacon-active.log`:
- citsensorservice: graphics.common V6 -> V7, matching the source libgralloctypes
  dependency and the existing common extractor's corresponding fixup.
- libswspatializeraidl_ext: audio.effect V3 -> V4 and media.audio.common.types
  V4 -> V5, matching the platform audio conversion library's AIDL generation.

These are DT_NEEDED replacements, recorded with original/output hashes in
`stock-evidence/vendor-selection.json`; the extraction script reproduces them.
Original staged files are saved under `out/nezha-bringup/aidl-originals`.
Regeneration verified all 3101 staged file hashes. ELF symbol checking remains
active. This resolves graph version selection only; runtime audio/sensor and
cross-version ABI compatibility are not yet established. No flash performed.

The next graph pass exposed the same audio version mismatch across the connected
HAL/effect/Bluetooth libraries. Eighteen additional stock-derived files now use
audio core/effect/sounddose V4, audio common types V5, and Bluetooth audio V6
where they previously linked the older versions. Each replacement and hash is
pinned in the same selection manifest, with originals retained under out.
No additional ELF checks were disabled. Cross-version runtime ABI validation
remains outstanding.

After audio alignment, Soong progressed to the display composer service:
its stock composer3 V1 dependency conflicted with source composer3 V4.
The service's DT_NEEDED reference now selects V4, with the same manifest,
hash, reproduction and original-backup records. Prior graph error log:
`out/nezha-bringup/bacon-20260920-composer-conflict.log`.
Display runtime compatibility still requires device validation.

Next graph stage: eight more files aligned for media C2 V1 -> V2,
graphics.common V5 -> V7, media.audio.common.types V4-cpp -> V5-cpp,
and Xiaomi camera injection's camera.device V1 -> V3 dependencies.
Media/graphics/audio CPP changes match the existing common extractor's
version migrations. Camera injection retains its Xiaomi V1 interface;
only its imported platform library changes. All original/output identities
are pinned, with no new dependency-check suppression. Error evidence:
`out/nezha-bringup/bacon-20260920-media-conflicts.log`.

Further camera graph conflicts required graphics.allocator V1 -> V2 in the
Dewarp node and offlinecamera implementation, plus Qualcomm offlinecamera
V2 -> V3 (the local V3 interface imports camera.device V3). Both modified
files are hash-pinned and reproducible like the preceding changes.
See `out/nezha-bringup/bacon-20260920-camera-conflicts.log`.

Dolby C2 is a deliberate exception: platform libcodec2_aidl still imports
C2 V1, whereas libcodec2_aidl_noisurface imports V2. Restored the Dolby
service to its exact original stock hash and removed its proposed C2
migration from the manifest/list. Qualcomm media services retain V2.

Milestone: complete Soong graph generation succeeded (7m36s) after these
corrections. Build advanced through Make module parsing and packaging rule
generation, including licensing/SBOM checks. This is not yet a completed ROM.

Ninja startup found duplicate installed symbol paths for libdng_sdk.so and
libtensorflowlite_c.so: module-only aliases did not prevent collisions with
platform vendor variants. The Xiaomi libraries now install as
libdng_sdk_vendor.so and libtensorflowlite_c_vendor.so, with matching SONAMEs
and five stock consumer DT_NEEDED changes. Extraction now supports explicit,
manifest-pinned output_path aliases within the same partition. Source hashes,
output hashes, transforms and list destinations remain validated. This
supersedes the earlier build-only-alias approach. No platform modules removed.

Reproduction check: all 66 transformed blobs were regenerated from pinned
stock inputs in a temporary directory; every output SHA-256 matched.
A local incremental resume wrapper is available at
`out/nezha-bringup/resume-local-build.sh` (not launched alongside the running
build). It records timestamped logs, exit status and successful ROM hashes;
it performs no sync, clean, upload or automatic retry.
