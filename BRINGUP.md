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
