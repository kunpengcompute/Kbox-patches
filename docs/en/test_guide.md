# Acceptance Test Guide<a id="ZH-CN_TOPIC_0000002552663615"></a>

<!-- md-trans-meta sourceCommit=d43551c76ea35df62b20feebd7cb9fb9bd9f829b translatedAt=2026-09-18T11:09:24.257Z pushedAt=2026-09-22T06:09:41.635Z -->

## Overview<a id="ZH-CN_TOPIC_0000002518186314"></a>

### Acceptance Criteria<a id="ZH-CN_TOPIC_0000002549706091"></a>

This document provides guidance for accepting cloud phone products. Before the acceptance, ensure that the physical environment, system environment, and software version are correct. The test cases in this document are designed by the cloud phone product test team, covering the basic functions of the Kbox cloud phone.

### Precautions<a id="ZH-CN_TOPIC_0000002549826087"></a>

1. Before the acceptance, ensure that the physical environment, system environment, and software version are correct and compatible.
2. Before executing the acceptance test cases, deploy the end-to-end Kbox cloud phone environment. For details, see [Installation Guide](install_guide.md).
3. All acceptance items shall be confirmed by Huawei and the customer.
4. During the product acceptance and preliminary acceptance tests, both parties should strictly observe applicable test criteria. Because some items have been tested before delivery, you can omit or sample such items if site conditions are limited.

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>Perform the acceptance in accordance with the contract and agreement reached by both parties. This document serves as a reference only.

## Test Preparations<a id="ZH-CN_TOPIC_0000002518186316"></a>

For details about the server hardware and software package information, environment deployment before test case acceptance, and the density test method, see [Installation Guide](install_guide.md). For details about the BIOS, iBMC, and CPLD versions, see [Release Notes](release_notes.md).

## Test Conventions<a id="ZH-CN_TOPIC_0000002549706087"></a>

### Result Description<a id="section62693428"></a>

The test results are defined as follows:

- **PASS**: The test result is consistent with the expected result after a test is performed based on the prerequisites and preset procedure.
- **FAIL**: The test result is inconsistent with the expected result after a test is performed based on the prerequisites and preset procedure.
- **NT**: The test is not implemented because the requirements have changed or the test environment does not meet the requirements.

## Test Cases and Records<a id="ZH-CN_TOPIC_0000002518346236"></a>

### Basic Functional Tests<a id="ZH-CN_TOPIC_0000002518186318"></a>

#### Creating a Kbox Cloud Phone Container<a id="ZH-CN_TOPIC_0000002549826089"></a>

<a id="table27768935"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.1 |
| Test Objective| Verify that a Kbox cloud phone container can be created.|
| Test Networking| None|
| Prerequisites| The basic environment of the Kbox cloud phone has been deployed.|
| Test Procedure | 1. Run the `./android11_kbox.sh start kbox_image:tag <x> <y>` command to create Kbox cloud phone containers.<br>Note: `x` and `y` indicate the start and end IDs of containers to be created, respectively. For example, to create containers 1 to 9, replace `x` with `1` and `y` with `9`. To create only one container, enter a value to replace `x` only.<br>2. Run the `docker ps -a` command to view the created Kbox cloud phone container and its status. |
| Expected Result| 1. A message is displayed, indicating that the Kbox cloud phone container is successfully created.<br>2. The created device and its status are displayed.|
| Test Result|    |
| Remarks|    |

#### Restarting a Kbox Cloud Phone Container<a id="ZH-CN_TOPIC_0000002549706089"></a>

<a id="table26778736"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.2 |
| Test Objective| Verify that a Kbox cloud phone container can be restarted.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Test Procedure | 1. Run `./android11_kbox.sh restart <x>` to restart the started Kbox cloud phone container. <br>Note: `x` indicates the numeric part of the container ID.<br>2. Run `docker ps -a` to check the Kbox cloud phone container that has been successfully restarted and its status. |
| Expected Result| 1. A message is displayed, indicating that the Kbox cloud phone container is successfully restarted.<br>2. The restarted device and its status are displayed.|
| Test Result|    |
| Remarks|    |

#### Deleting a Kbox Cloud Phone Container<a id="ZH-CN_TOPIC_0000002518346234"></a>

<a id="table24712267"></a>

| Item| Description  |
|---|---|
| Case No.| 4.1.3 |
| Test Objective| Verify that a Kbox cloud phone container can be deleted.|
| Test Networking| None|
| Preconditions| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Test Procedure | 1. Run `./android11_kbox.sh delete <x>` to delete the Kbox cloud phone container. <br>Note: `x` indicates the numeric part of the container ID.<br>2. Run `docker ps -a` to view the Kbox cloud phone containers in the current environment. |
| Expected Result | 1. A success flag is returned after the Kbox cloud phone container is deleted.<br>2. The list of Kbox cloud phone containers does not contain the deleted Kbox cloud phone container. |
| Test Result|    |
| Remarks|    |

#### Querying the Kbox Cloud Phone Container Status<a id="ZH-CN_TOPIC_0000002549826077"></a>

<a id="table35101782"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.4 |
| Test Objective| Verify that the Kbox cloud phone container status can be queried.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Test Procedure | 1. Run `docker ps -a` to view the Kbox cloud phone containers in the current environment.<br> 2. Run `docker exec -it kbox_<x> sh` to enter the Kbox cloud phone container, and then run `getprop \| grep sys.boot_completed` to query the container running status. <br>Note: `x` indicates the numeric part of the container ID. |
| Expected Result | 1. The queried device is displayed in the Kbox cloud phone list.<br>2. The value of the `sys.boot_completed` parameter of the queried Kbox cloud phone is `[1]`, indicating that the Kbox cloud phone has started successfully. |
| Test Result|    |
| Remarks|    |

#### Kbox Cloud Phone Container ADB Test<a id="ZH-CN_TOPIC_0000002549706085"></a>

<a id="table21405834"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.5 |
| Test Objective| Verify the connection and disconnection between the Kbox cloud phone container and ADB.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Test Procedure| 1. Run the `adb connect [ip:port]` command to connect to a single container.<br>Note: `ip:port` indicates the deployment IP address of the Kbox cloud phone and the port number of the started container, respectively. Replace them with the actual values.<br>2. Run the `adb disconnect [ip:port]` command to disconnect from a single container.|
| Expected Result| 1. If "connected to *ip:port*" is displayed in the command output, the ADB connection to the Kbox cloud phone container is successful.<br>2. If "disconnected *ip:port*" is displayed, the ADB disconnection from the Kbox cloud phone container is successful.|
| Test Result|    |
| Remarks|    |

#### Resource Isolation Test<a id="ZH-CN_TOPIC_0000002518346226"></a>

<a id="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.6 |
| Test Objective| Verify that the resource isolation function of a Kbox cloud phone is normal.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.|
| Test Procedure | 1. CPU resource isolation verification: Execute the command `docker exec -it kbox_<x> cat /proc/cpuinfo \| grep processor`.<br>2. Memory resource isolation verification: Execute the command `docker exec -it kbox_<x> cat /proc/meminfo \| grep MemTotal`.<br>3. Storage resource isolation verification: Execute the command `df -h \| grep -w kbox_<x>`. <br>Note: `x` indicates the numeric part of the container ID. |
| Expected Result| 1. The queried CPU core count of a single container matches the specifications in the feature guide.<br>2. The queried memory size of a single container matches the specifications in the feature guide.<br>3. The queried storage space of a single container matches the specifications in the feature guide.|
| Test Result|    |
| Remarks|    |

#### GPS Mock Test<a id="ZH-CN_TOPIC_0000002549706077"></a>

<a id="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.7 |
| Test Objective| Verify the GPS mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.<br>3. Baidu Map or AMap has been installed in the container.|
| Test Procedure| 1. Use ARDC to connect to the Kbox cloud phone container and display the GUI.<br>2. Open Baidu Map or AMap to view your current location.|
| Expected Result| The current location is the preset mock location (Hangzhou Research Center of Huawei).|
| Test Result|    |
| Remarks|    |

#### IMEI Mock Test<a id="ZH-CN_TOPIC_0000002518186306"></a>

<a id="table9347770"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.8 |
| Test Objective| Verify the IMEI mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br> 2. The Kbox cloud phone container has been created and connected via ARDC to display the cloud phone UI.|
| Test Procedure | 1. On the dial-up screen of the cloud phone, enter `*#06#`, or run the command `docker exec -it kbox_<x> getprop persist.sys.prop.writeimei` on the server to query the IMEI value.<br>2. On the server, run the command `docker exec -it kbox_<x> setprop persist.sys.prop.writeimei imei_num` to modify the IMEI value. The new value must be a valid 15-digit number.<br>3. After the `setprop` setting is complete, run the command `docker exec -it kbox_<x> getprop persist.sys.prop.writeimei` on the server to query the IMEI value. <br>Note: `x` indicates the numeric part of the container ID. |
| Expected Result| 1. The IMEI preset in the Kbox cloud phone container is displayed.<br> 2. After the IMEI is changed on the server, the new IMEI is displayed in the query result.|
| Test Result|    |
| Remarks|    |

#### Wi-Fi Mock Test<a id="ZH-CN_TOPIC_0000002549826083"></a>

<a id="table11771810"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.9 |
| Test Objective| Verify the Wi-Fi mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created.<br>3. AnTuTu has been installed on the Kbox cloud phone. (AnTuTu is used to activate the Wi-Fi mock function.)|
| Test Procedure| 1. Open AnTuTu and grant required permissions.<br>2. On the homepage, choose `My Device` > `Hardware` to view related configurations.|
| Expected Result| The Wi-Fi information is displayed under `Hardware`.|
| Test Result|    |
| Remarks|    |

#### Sensor Mock Test<a id="ZH-CN_TOPIC_0000002518186312"></a>

<a id="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.10 |
| Test Objective | Verify the sensor (acceleration and gyroscope) mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.<br>3. AnTuTu has been installed on the Kbox cloud phone.|
| Test Procedure| On AnTuTu Benchmark, choose `My Device` > `Hardware` > `Sensors`.|
| Expected Result| `Acceleration Sensor` and `Gyroscope Sensor` are displayed under `Sensors`.|
| Test Result|    |
| Remarks|    |

#### Creating a vinput Device<a id="creating-a-vinput-device"></a>

<a id="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.11 |
| Test Objective| Verify the function of creating a vinput device (mouse/gamepad).|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via ADB.|
| Test Procedure | 1. Open a server remote connection window A, and run the command `docker exec -it kbox_<x> setprop persist.sys.input.[mouse/gamepad1/gamepad2].name <xxx>` to set the names of the mouse/gamepad 1/gamepad 2 respectively. <br>Note: `x` indicates the numeric part of the container ID, and `xxx` is a combination of letters, digits, or underscores with a length not exceeding 64 characters.<br>2. After the setting is complete, run `docker exec -it kbox_<x> getevent` to query the set device names. |
| Expected Result | 1. The device names are created successfully without any error message.<br>2. The created devices can be queried and their names are correct. |
| Test Result|    |
| Remarks|    |

#### Sending and Receiving vinput Device Events<a id="ZH-CN_TOPIC_0000002518186304"></a>

<a id="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.12 |
| Test Objective| Verify that a vinput device can properly send and receive events.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via ADB.|
| Test Procedure | 1. After setting [vinput devices](#creating-a-vinput-device), open another server remote connection window B and enter the command `getevent` to listen for events.<br>2. In server remote connection window A, run the command `docker exec -it kbox_<x> sh` to enter the container. Run the command `getevent -p` to obtain the `[device][type][code][value]` parameters of the corresponding event.<br>3. In the container, run the command `sendevent [device] [type] [code] [value]` to send the event. <br>Note: `x` indicates the numeric part of the container ID. |
| Expected Result| No error is reported when window A sends events, and window B can successfully listen to the events.|
| Test Result|    |
| Remarks|    |

#### Modifying GPS Mock Properties<a id="ZH-CN_TOPIC_0000002518346228"></a>

<a id="table60533823"></a>

| Item | Content |
|---|---|
| Case No. | 4.1.13 |
| Test Objective | Verify that the values of GPS mock properties can be modified and queried. |
| Test Networking | None |
| Prerequisites | 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. One Kbox cloud phone container has been created and connected. |
| Test Procedure | 1.<a id="step1"></a> In the CMD window on the PC, after connecting to the container, run the command `adb -s [ip:port] shell setprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed] <xx>` to modify the values of the GPS properties respectively. <br>Note: `xx` is the valid value of each property. *ip:port* (replace with the actual IP address and port number) is the deployment IP address of the Kbox cloud phone and the port corresponding to the started container.<br>2. In the CMD window on the PC, run the command `adb -s [ip:port] shell getprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed]` to query the values of the GPS properties. |
| Expected Result | 1. No error message about setting failure is displayed.<br>2. The values of the GPS properties set in test step [1](#step1) can be queried, and the values are correct. |
| Test Result |  |
| Remarks |  |

#### Setting Sensor Properties<a id="ZH-CN_TOPIC_0000002549706079"></a>

<a id="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.14 |
| Test Objective| Verify that the sensor mock properties on the three axes (x, y, and z) and data collection frequency properties can be modified.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via ADB.|
| Test Procedure | 1. In the CMD window on the PC or on the server, run the command `adb -s [ip:port] shell setprop persist.sensors.mock.[acce/gyro].data.[x/y/z] <xx>` (`xx` is any value within ±3.402823466e+38) to modify the x/y/z-axis parameters of the sensor (`acce` indicates the acceleration sensor, and `gyro` indicates the gyroscope).<br>2. Open `sensors_test.apk` to query the values of each sensor property.<br>3. In the CMD window on the PC or on the server, run the command `adb -s [ip:port] shell setprop persist.sensors.mock.delaytime <xx>` (`xx` is any value within [20000,1000000]) to set the data collection frequency property value in the sensor mock.<br>4. Perform steps 1 and 2 again.<br>5. Observe the change duration of the property values of the modified sensor after the data collection frequency is modified. |
| Expected Result| 1. No error is reported during the setting.<br>2. The parameters are set successfully.<br>3. The parameters are queried successfully.<br>4. The change duration of the sensor property values varies with the data collection frequency.|
| Test Result|    |
| Remarks|    |

#### Kbox Component Version Query Test<a id="ZH-CN_TOPIC_0000002518346230"></a>

<a id="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.15 |
| Test Objective| Test the function of querying the Kbox component version.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via ADB.|
| Test Procedure | 1. Run `sudo docker exec -it kbox_<x> sh` to enter the Kbox cloud phone container.<br> 2. Run `cat /vendor/etc/kbox_version.txt` to query the version number. |
| Expected Result| 1. The container is accessible.<br>2. The correct Kbox component version information is displayed as follows. (The specific version number is subject to the version in use.)<br>Product Name: Kunpeng BoostKit<br>Product Version: xxx<br>Component Name: BoostKit-boostcph-kbox<br>Component Version: xxx<br>Component AppendInfo: 11.0.0_r48 |
| Test Result|    |
| Remarks|    |

#### Testing the Hardware Decoding Video Playback Capability of the Kbox Cloud Phone<a id="ZH-CN_TOPIC_0000002518346232"></a>

<a id="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.16 |
| Test Objective| Test the hardware decoding video playback capability of the Kbox cloud phone.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via ADB.<br> 3. XPlayer has been installed in the Kbox cloud phone container.<br>|
| Test Procedure | 1. Set the Kbox cloud phone to use the hardware decoder of the NETINT T432/NETINT QUADRA T2A codec card as instructed in the feature guide.<br> 2. Import videos in 264_1280x720_30fps/265_1280x720_30fps format into the container.<br> 3. Use XPlayer to play the imported videos completely. |
| Expected Result | 1. During video playback, the picture is normal without frame freezing, and no abnormal frames (such as artifact, black, or green screens) appear. The hardware decoder name (OMX.media.video.decoder) can be found in the logs. |
| Test Result|    |
| Remarks|    |

#### IMSI Mock Test<a id="ZH-CN_TOPIC_0000002549706081"></a>

<a id="table9347770"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.17 |
| Test Objective| Verify the IMSI mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. The Kbox cloud phone container has been created and connected via ARDC to display the cloud phone UI.|
| Test Procedure | 1. On the cloud phone dial-up screen, enter `*#*#4636#*#*` to query the IMSI value. 2. In the PC terminal window, run the command `adb connect [ip:port]` to connect to the specified container.<br>3. In the PC terminal window, run the command `adb -s [ip:port] shell setprop persist.sys.prop.writeimsi <xx>`, restart the Kbox cloud phone, and query the IMSI value again. <br>Note: `xx` indicates a valid IMSI value. |
| Expected Result| 1. The preset IMSI of the Kbox cloud phone container (which is 46011 + random digits) is displayed.<br>2. After the IMSI is changed on the server, the new IMSI is displayed in the query result.|
| Test Result|    |
| Remarks|    |

#### Querying Network Operator Information and SIM Card Information<a id="ZH-CN_TOPIC_0000002518186308"></a>

<a id="table9347770"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.18 |
| Test Objective| Verify the function of querying network operator information and SIM card information.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. The Kbox cloud phone container has been created and connected via ARDC to display the cloud phone UI.<br>3. The `zausan.zdevicetest.apk` file has been installed in the Kbox cloud phone container.|
| Test Procedure | 1. Run `sudo docker exec -it kbox_<x> sh` on the server to enter the Kbox cloud phone container.<br>2. Enter `dumpsys isub \| grep -i iccid` to query the SIM card serial number.<br>3. Open SSM/UMTS in `zausan.zdevicetest.apk` on the client.<br>4. View `SIM operator/SIM operator name/SIM country/Network operator/Network operator name/Network country/Line one number` to obtain the SIM card operator code, SIM card operator name, SIM card operator country code, network operator code, network operator name, network operator country code, and phone number.<br>5. After connecting to the container in the CMD window on the PC, run the command `adb -s [ip:port] shell setprop persist.[sys.prop.writesimserial/gsm.sim.operator.alphacph/sys.prop.writeimsi/gsm.operator.numericcph/gsm.operator.alphacph/gsm.operator.numericcph/sys.prop.writephonenum] <xx>` to modify the property values. <br>Note: `xx` is the valid value of each property. *ip:port* (replace with the actual IP address and port number) is the deployment IP address of the Kbox cloud phone and the port corresponding to the started container.<br>6. Restart the Kbox cloud phone and query each value again. |
| Expected Result | 1. The default initial value of the SIM card serial number preset in the current Kbox cloud phone container is displayed: 898600+random digits+[****].<br>2. The default initial values of the SIM card operator code, SIM card operator name, SIM card operator country code, network operator code, network operator name, and network operator country code preset in the current Kbox cloud phone container are displayed as 46011/CMCC/cn/46000/CMCC/cn respectively, and the default initial value of the phone number is empty.<br>3. The new property values of the current Kbox cloud phone container are displayed. |
| Test Result|    |
| Remarks|    |

## Test Result Analysis<a id="ZH-CN_TOPIC_0000002549826081"></a>

### Basic Test Information<a id="ZH-CN_TOPIC_0000002518346222"></a>

<a id="table56604068"></a>

| Item| Description|
|---|---|
| Device Manufacturer |  |
| Device Model |  |
| Test Location |  |
| Test Personnel |  |
| Test Time |  |
| Other Information |  |

### Test Result List<a id="ZH-CN_TOPIC_0000002549826079"></a>

|Test Type|Case No.|Case Name|Test Result (PASS/FAIL/NT)|
|--|--|--|--|
|Basic functional tests|4.1.1|Creating a Kbox cloud phone container|
||4.1.2|Restarting a Kbox cloud phone container|
||4.1.3|Deleting a Kbox cloud phone container|
||4.1.4|Querying the Kbox cloud phone container status|
||4.1.5|Kbox cloud phone container ADB test|
||4.1.6|Resource isolation test|
||4.1.7|GPS mock test|
||4.1.8|IMEI mock test|
||4.1.9|Wi-Fi mock test|
||4.1.10|Sensor mock test|
||4.1.11|Creating a vinput device|
||4.1.12|Sending and receiving vinput device events|
||4.1.13|Modifying GPS mock properties|
||4.1.14|Setting sensor properties|
||4.1.15|Querying the Kbox component version|
||4.1.16|Testing the hardware decoding video playback capability of the Kbox cloud phone|
||4.1.17|IMSI mock test|
||4.1.18|Querying network operator information and SIM card information|

## Customer Suggestions and Result Confirmation<a id="ZH-CN_TOPIC_0000002549826075"></a>

### Customer Suggestions<a id="ZH-CN_TOPIC_0000002549706083"></a>

### Result Confirmation<a id="ZH-CN_TOPIC_0000002549826073"></a>

|Tested Party: Huawei Technologies Co., Ltd.|Testing Party:|
|--|--|
|Test Personnel Signature:|Test Personnel Signature:|
|Date:|Date:|

## Change History

|Release|Date|Description|
|--|--|--|
|01|2026-09-30|This is the first official release.|
