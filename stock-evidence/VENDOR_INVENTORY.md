# Nezha 309 vendor inventory and extraction preparation

Source: verified CN Android 16 OS3.0.309.0.WPACNXM extracted partitions only. Existing image verification is reused, not repeated. Every selected regular file has fresh SHA-256 and SHA-1 identity.

- inventory_entries: 12509
- inventory_by_partition: {'vendor': 3689, 'odm': 2935, 'product': 1989, 'system_ext': 3276, 'vendor_dlkm': 392, 'system_dlkm': 228}
- selected_device_blobs: 1374
- selected_common_blobs: 1722
- selected_bytes: 4727551941
- reference_entries: {'device': 1588, 'common': 1739}
- missing_expected_entries: {'device': 205, 'common': 15}
- missing_unique_paths: 220
- missing_unique_by_group: {'device': 205, 'common': 15}
- selected_from_verified_replacements: 0
- stock_paths_outside_reference_union: 9413
- fixup_operations_audited: 146
- fixup_operations_pending: 124
- fixup_blobs_pending: 98
- reference_options_or_aliases_audited: 116
- reference_options_or_aliases_pending: 69
- applied_binary_fixups: 0
- verified_stock_symlinks: 9
- verified_sql_filegroup_members: 28
- resolved_module_name_collisions: 3

Selection is a draft exact-path intersection of actual stock files with category references. Common paths take precedence for ownership. Identical paths are not claims of identical device hardware or cross-device byte identity. No alternate basename is accepted as a Nezha replacement without evidence. All missing paths and unselected stock files remain visible in the inventory; this is not a complete boot-ready vendor set. DLKM inventory is included, but the existing validated kernel module tree is not duplicated into these lists.

`vendor-path-comparison.tsv` contains every reference entry, including destination aliases and candidates for absent paths. `vendor-selection.json` is the sole copy allowlist. `proprietary-files-common.txt` stays under the Nezha device directory so the existing shared-device list and its foreign fixups remain untouched.

Reference fixups are inspected as AST data, never executed. DT_NEEDED, SONAME, symbol-version, text and byte-pattern preconditions are checked against the real stock file; matching preconditions alone do not establish that a patch is correct. Every operation is documented in `vendor-fixup-audit.json`. No binary patch, SONAME change, symbol-version removal, unchecked alias or check-ELF bypass is enabled.

Verified build metadata is recorded in vendor-build-metadata.json: three partition-specific module aliases, 28 real SQL files, nine stock symlinks and PRESIGNED stock APKs. These modify build descriptions only. Remaining option rows exclude these resolved cases.
