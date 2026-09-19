# Nezha 309 bring-up status

Stock: OS3.0.309.0.WPACNXM, Android 16, CN only.
The first real lineage_nezha build is authorized only after hard static blockers are closed. No build or flash has run.

Current detailed evidence is authoritative over earlier historical audit snapshots:
- `stock-evidence/uapi-resolution.tsv`: 9 missing permissible UAPI definitions; 3 IPA source candidates awaiting export/ABI resolution.
- `stock-evidence/vendor-missing-classification.tsv`: all 220 comparison paths; class counts 109/7/9/0/1/94. Missing comparison paths are not automatically Nezha errors.
- `stock-evidence/vendor-fixup-validation.tsv`: all 124 operations; 7 applied, 56 rejected/not required, 61 tinyxml2 ABI decisions open.
- `stock-evidence/vendor-list-option-classification.tsv`: all 69 cases classified; 9 SONAME fixes, 16 packaging destinations, 5 required dependencies applied, 38 not imported, 1 fingerprint loader blocker.
- `stock-evidence/vendor-static-validation.json`: 3096 stock-derived blobs (1374 device/1722 common), 15 transformed payloads, 1791 unique generated modules, no missing literal sources or broken selected symlinks. This does not evaluate the Soong graph.
- `stock-evidence/repository-ownership.json`: repository ownership and future publication boundaries; nothing published.

All source and resulting hashes and reviewed transformations are pinned in `stock-evidence/vendor-selection.json`. The extraction script reproduces only these transformations; setup validates the staged result and emits vendor descriptions without compiling. Already staged blobs were not re-extracted. Stock EcoInfoDynamic.json remains unchanged.

Kernel/DTB/DTBO/module provenance from the earlier completed pass remains valid. No shared source/core edits or foreign-device payload have been introduced. Device hardware integration and ABI questions still prevent build readiness.
