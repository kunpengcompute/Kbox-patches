# Release Notes<a name="ZH-CN_TOPIC_0000002521895828"></a>

<!-- md-trans-meta sourceCommit=a0e3693322469c84660413f959e180326c482c4f translatedAt=2026-09-22T14:23:22.736Z pushedAt=2026-09-24T05:54:02.888Z -->

## Version Mapping<a name="ZH-CN_TOPIC_0000002518186090"></a>

### Product Version<a name="ZH-CN_TOPIC_0000002549825865"></a>

|Item|Content|
|--|--|
|Product Name|Kunpeng BoostKit|
|Product Version|26.2.RC1|
|Software Name|Kbox cloud phone container|
|Software Package Version|8.2.0_15|

### Software Version Mapping<a name="ZH-CN_TOPIC_0000002549705863"></a>

|Software|Version|Remarks|
|--|--|--|
|Kunpeng BoostKit|Kunpeng BoostKit 26.2.RC1|-|
|OS|openEuler 24.03 LTS SP1 AArch64 (kernel 6.6.0-72.0.0)|-|
|ExaGear|ExaGear_ARM32-ARM64|Transcoding software|

### Hardware Version Mapping<a name="ZH-CN_TOPIC_0000002549705865"></a>

|Server|Processor|BIOS Version|CPLD Version|BMC Version|
|--|--|--|--|--|
|Kunpeng server|Kunpeng 920 processor|6.57|5.09|6.49|
|Kunpeng server|New Kunpeng 920 processor model|33.70|5.10|26.01.62.25|

## Important Notes<a name="ZH-CN_TOPIC_0000002549825861"></a>

Please refer to the *Feature Guide* of the corresponding version, for example, [Feature Guide](./feature_guide.md).

## V8.2.RC1_11<a id="V8.2.RC1_11"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186202"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|---|---|---|
|1|Shared data volume| Kbox supports the shared data volume feature. |

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549705975"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549825953"></a>

None

## V8.1.RC1_11<a id="ZH-V8.1.RC1_11"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186202"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|---|---|---|
|1|NFS mount| Kbox supports NFS mount. |
|2|Enhanced CPU/F2FS file system/System partition/init process emulation| To enhance system emulation capabilities. |

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549705975"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549825953"></a>

None

## V8.0.RC1_11<a id="V8.0.RC1_11"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186202"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|---|---|---|
|1|Codec 2.0| Kbox supports the Codec 2.0 encoding and decoding framework. |

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549705975"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549825953"></a>

None

## V7.3.0_15<a name="ZH-CN_TOPIC_0000002549705869"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002518186094"></a>

**New Features<a name="section78241436103817"></a>**

|No.|Feature|Purpose|
|--|--|--|
| 1 | Android 15 cloud phone features | Adapted the Kbox cloud phone container to Android 15, achieving system boot, image output, SCRCPY stream output, and hardware emulation (including GPS, sensors, and Telephony) on Android 15.|

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002518346010"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002518186096"></a>

<a name="table1427894420453"></a>

|Severity|Issue Description|Cause Analysis|Impact Assessment|Workaround|Solution|
|--|--|--|--|--|--|
|Minor|When running an Android 15 cloud phone in the DC1000/DC1000C environment with the RC13-A15 driver, the benefits of enabling adaptive vsync are unstable.|After this feature is enabled, due to a lack of adaptation in the frame capture component of the DaoCloud driver, the capture process occasionally utilizes data from the previous frame. Consequently, an image intended for display at frame *t* is delayed at frame *t* + 1, resulting in increased latency.|No user-perceivable visual anomalies occur during normal application usage when this feature is enabled.|No workaround is available for now.|The GPU vendor will update the driver to fix this issue.|

## Related Documentation<a name="ZH-CN_TOPIC_0000002549825863"></a>

### V7.3.0_15 Documentation<a name="ZH-CN_TOPIC_0000002518186092"></a>

|No.|Document|Introduction|How to Obtain|
|--|--|--|--|
| 1 | best_practices | Describes the best practices of the Kbox cloud phone container.| [Best Practices](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/best_practices.md)|
| 2 | compile_guide | Describes how to compile the Kbox cloud phone container.| [Compilation Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/compile_guide.md)|
| 3 | feature_guide | Describes the features of the Kbox cloud phone container.| [Feature Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/feature_guide.md)|
| 4 | install_guide | Describes how to install the Kbox cloud phone container.| [Installation Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/install_guide.md)|
| 5 | release_notes | Describes version information about the Kbox cloud phone container.| [Release Notes](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/release_notes.md)|
| 6 | test_guide | Describes how to test the Kbox cloud phone container.| [Acceptance Test Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/test_guide.md)|
| 7 | troubleshooting | Describes the troubleshooting cases of the Kbox cloud phone container.| [Troubleshooting Cases](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/troubleshooting.md)|
| 8 | user_guide | Describes how to use the Kbox cloud phone container.| [User Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/user_guide.md)|
| 9 | routine_maintenance | Describes the maintenance methods and tools for the Kbox cloud phone container.| [Routine Maintenance](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/routine_maintenance.md)|

### Obtaining Documentation<a name="ZH-CN_TOPIC_0000002549825867"></a>

View or download required documents from [menu](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/en/menu.md).
