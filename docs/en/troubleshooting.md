# Troubleshooting Cases<a name="ZH-CN_TOPIC_0000002552775783"></a>

<!-- md-trans-meta sourceCommit=0bc3f2ec41a7e20eab89b2f3abf05a028614903a translatedAt=2026-09-22T14:43:00.189Z pushedAt=2026-09-24T03:02:27.464Z -->

## Troubleshooting 32-bit Application Faults<a name="ZH-CN_TOPIC_0000002518226310"></a>

**Symptom<a name="section6713450123511"></a>**

32-bit applications are faulty; for example, applications cannot be started or crash on startup. However, 64-bit applications are normal.

**Impact on the System<a name="section1883411169412"></a>**

All 32-bit applications are affected.

**Possible Causes<a name="section1777888184213"></a>**

If only 32-bit applications are faulty, the transcoding software may be faulty. Possible causes are as follows:

1. The transcoding software fails to be registered.
2. The transcoding software version does not match.
3. The transcoding software patch is not installed.

**Procedure<a name="section12646853105012"></a>**

1. <a name="li1655995125318"></a>Run the following command to check whether the command output is normal. If `enable` is displayed, the command output is normal.

    ```bash
    cat /proc/sys/fs/binfmt_misc/ubt_a32a64
    ```

2. If the command output is abnormal, run the following command to register the transcoding software again:

    ```bash
    echo ":ubt_a32a64:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfe\xff\xff\xff:/opt/exagear/ubt_a32a64:POCF" > /proc/sys/fs/binfmt_misc/register
    ```

3. Perform [1](#li1655995125318) again and check whether the command output is normal.
4. Run the following command to check the transcoding software version:

    ```bash
    /opt/exagear/ubt_a32a64 -V
    ```

5. Compare the displayed software version with the transcoding software version in the version mapping table. If the versions do not match, contact technical support to obtain the matching software version.

    If the fault persists, collect information and contact technical support.

## Troubleshooting Patch Integration Faults<a name="ZH-CN_TOPIC_0000002518386224"></a>

**Symptom<a name="section111416358916"></a>**

Image compilation fails, and alarm information is displayed.

**Impact on the System<a name="section1188785910917"></a>**

The system cannot compile and generate normal images, and services cannot run.

**Possible Causes<a name="section393416205106"></a>**

1. The patch fails to be integrated.
2. The patch is not completely integrated.
3. The patch version does not match the source code version.

**Procedure<a name="section89841336161010"></a>**

1. Run the following command to search for the `.rej` file in the compilation directory:

    ```bash
    find ./ -name "*.rej"
    ```

    If a file with the same name without `.rej` can be found, the file is faulty. In this case, contact technical support.

2. Check the source code version and match it with the version specified in the version mapping table. If the source code version does not match the version specified in the table, use the specified version.

## Troubleshooting System Breakdown<a name="ZH-CN_TOPIC_0000002518386232"></a>

**Symptom<a name="section55241852162719"></a>**

The server breaks down in some scenarios.

**Impact on the System<a name="section69995352720"></a>**

The system is unavailable and services are interrupted.

**Possible Causes<a name="section854711548271"></a>**

1. The software version does not match.
2. Server configurations are incorrect.

**Procedure<a name="section12953654202714"></a>**

Check the memory and BIOS configurations by referring to [Configuring the BIOS](install_guide.md#configuring-the-BIOS).

## Change History

|Release|Date|Description|
|--|--|--|
|01|2026-09-30|This is the first official release.|
