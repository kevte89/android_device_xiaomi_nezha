# UAPI classification — Nezha 309

The original 100 are direct source includes, not names collected from Android.bp, modules.*, depmod or binaries. The original audit did not evaluate module selection or preprocessor guards. Its broader 174-row union also contains 66 reference-only names.

The full deduplicated table with every source location and build-module evidence is `uapi-classification.tsv`; structured details and contexts are in `uapi-classification.json`. Build-generation evidence: `out/nezha-review-309/header-build-rules.json`.

## Original 100

- original_100: 100
- false_positive_current_userspace: 91
- generated_with_verified_input_and_rule: 0
- available_compatible_exported_source: 0
- qualcomm_sm8850_interface_class_B: 9
- xiaomi_class_C: 0
- unclassified_class_F: 0
- unresolved_compatible_source: 9
- literal_path_hits_anywhere_in_tree: 23
- literal_hits_outside_comparison_tree: 8
- all_audit_rows: 174
- build_files_scanned: 16973

Literal file hits do not imply suitable headers. External test/compatibility headers and the comparison device kernel-header set are not an approved Nezha source. No A/C/D/F case was proven among the original 100; kernel-internal generic headers belong in E for this userspace audit, not A (UAPI). The 9 class-B cases are the same 9 unresolved compatible-source cases, not 18 separate headers.

## Remaining compatible-source questions

| Header | Module evidence | Comparison file | Status |
|---|---|---|---|
| `display/drm/msm_drm_aiqe.h` | libdrmutils, libsdedrm | absent | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |
| `display/drm/msm_drm_pp.h` | color_sampling_test, color_sampling_tool, libdrmutils, libhistogram, libsdedrm, libsdmdal | present in device kernel-header set; not copied | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |
| `display/drm/sde_drm.h` | libdrmutils, libgrallocutils, libsdedrm, libsdmdal, vendor.qti.hardware.display.snapalloc-impl | present in device kernel-header set; not copied | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |
| `display/media/mmm_color_fmt.h` | aidl_fuzzer_display_gralloc, android.hardware.graphics.mapper@4.0-impl-qti-display, libgralloc.qti, libgralloccore, libgrallocutils, libmapperutils, mapper.qti, mapperext_defaults, vendor.qti.hardware.display.allocator-service, vendor.qti.hardware.display.snapalloc-impl | present in device kernel-header set; not copied | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |
| `display/media/msm_sde_rotator.h` | libsdmdal | present in device kernel-header set; not copied | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |
| `linux/msm_audio.h` | libarosal_headers, liblx-osal | present in device kernel-header set; not copied | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |
| `linux/msm_ion.h` | libarosal_headers, libgralloccore, liblx-osal | present in device kernel-header set; not copied | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |
| `linux/qti-smmu-proxy.h` | aidl_fuzzer_display_gralloc, android.hardware.graphics.mapper@4.0-impl-qti-display, libgralloc.qti, libgralloccore, libgrallocutils, libmapperutils, mapper.qti, mapperext_defaults, vendor.qti.hardware.display.allocator-service, vendor.qti.hardware.display.snapalloc-impl | present in device kernel-header set; not copied | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |
| `misc/adsp_sleepmon.h` | libar-pal | present in device kernel-header set; not copied | Qualcomm userspace UAPI used by SM8850 sources; Nezha-309-compatible exported definition unresolved |

## Shared dependency route

Nezha already matches the comparison device's dependency structure: Common QCOM `audio_kernel_headers`, `qti_audio_kernel_uapi`, `qti_display_kernel_headers`, `qti_kernel_headers` and `smmu_proxy_uapi_header` use `generated_kernel_header_defaults`. `vendor/lineage/build/soong/Android.bp` invokes `headers_install` on the device's own `TARGET_KERNEL_SOURCE`, then exports `usr/include` and audio include roots. This generates an installation directory, not missing hardware definitions. Both device BoardConfigs point at their own `kernel-headers`. Therefore adding another dependency on these wrappers cannot supply absent Nezha UAPI. No dependency edit is justified.

`dataipa/drivers/platform/msm/Androidbp` contains IPA genrules with real local input headers, but its filename is not Android.bp. The active `qti_ipa_kernel_headers` wrapper is in hardware/qcom-caf/common. The three listed IPA UAPI output names are not among the original missing 100. No AIDL output can resolve a missing linux/ or display/ ioctl definition merely because aidl generation exists elsewhere.

Four legacy sound-trigger headers, two optional libvmmem headers and the old RMNET header are excluded from the blocker count. The source audio/PAL consumers of two class-B headers remain conditional because the common configuration requests prebuilts; no source/prebuilt selection is claimed without the completed vendor graph.

Outside the original 100, MediaDefs.h is an existing Android framework header exported through libstagefright_foundation, not Qualcomm UAPI. Three IPA UAPI files have real local SM8850 sources, but the active common wrapper still needs a verified export route; these are source-present integration questions, not missing-source cases.
