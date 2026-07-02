# Acceptance Test Guide<a name="ZH-CN_TOPIC_0000002552663615"></a>

## 1 Overview <a name="ZH-CN_TOPIC_0000002518186314"></a>

### 1.1 Acceptance Criteria<a name="ZH-CN_TOPIC_0000002549706091"></a>

This document provides guidance for accepting cloud phone products. Before the acceptance, ensure that the physical environment, system environment, and software version are correct. The test cases in this document are designed by the cloud phone product test team, covering the basic functions of the Kbox cloud phone.

### 1.2 Precautions<a name="ZH-CN_TOPIC_0000002549826087"></a>

1. Before the acceptance, ensure that the physical environment, system environment, and software version are correct and compatible.
2. Before executing the acceptance test cases, deploy the end-to-end Kbox cloud phone environment. For details, see [Installation Guide](install_guide.md).
3. All acceptance items shall be confirmed by Huawei and the customer.
4. During the product acceptance and preliminary acceptance tests, both parties should strictly observe applicable test criteria. Because some items have been tested before delivery, you can sample or omit such items if the site conditions are not appropriate.

>![](public_sys-resources/icon-note.gif) **NOTE**
>
>During acceptance tests, the contracts and the agreements reached between two parties take precedence, and this document serves as a reference only.

## 2 Preparations<a name="ZH-CN_TOPIC_0000002518186316"></a>

For details about the server hardware and software package information, environment deployment before test case acceptance, and the density test method, see [install_guide](install_guide.md). For details about the BIOS, iBMC, and CPLD versions, see [release_notes](release_notes.md).

## 3 Test Conventions<a name="ZH-CN_TOPIC_0000002549706087"></a>

**Result Description<a name="section62693428"></a>**

The test results in this document are defined as follows:

- `PASS`: The test result is consistent with the expected result after a test is performed based on the prerequisites and preset procedure.
- `FAIL`: The test result is inconsistent with the expected result after a test is performed based on the prerequisites and preset procedure.
- `NT`: The test case is not implemented because the requirements have changed or the test environment does not meet the requirements.

## 4 Test Cases and Test Records<a name="ZH-CN_TOPIC_0000002518346236"></a>

### 4.1 Basic Function Tests<a name="ZH-CN_TOPIC_0000002518186318"></a>

#### 4.1.1 Creating a Kbox Cloud Phone Container<a name="ZH-CN_TOPIC_0000002549826089"></a>

<a name="table27768935"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.1 |
| Test Objective| Verify that a Kbox cloud phone container can be created.|
| Test Networking| None|
| Prerequisites| The basic environment of the Kbox cloud phone has been deployed.|
| Procedure| 1. Run the `./android11_kbox.sh start kbox_image:tag x y` command to create Kbox cloud phone containers.<br><code>x</code> and <code>y</code> indicate the start and end IDs of containers to be created, respectively. For example, to create containers 1 to 9, replace <code>x</code> with <code>1</code> and <code>y</code> with <code>9</code>. To create only one container, enter a value to replace <code>x</code> only.<br>2. Run the `docker ps -a` command to view the created Kbox cloud phone container and its status.|
| Expected Result| 1. A message is displayed, indicating that the Kbox cloud phone container is successfully created.<br>2. The created device and its status are displayed.|
| Test Result|    |
| Remarks|    |

#### 4.1.2 Restarting a Kbox Cloud Phone Container<a name="ZH-CN_TOPIC_0000002549706089"></a>

<a name="table26778736"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.2 |
| Test Objective| Verify that a Kbox cloud phone container can be restarted.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Procedure| 1. Run the `./android11_kbox.sh restart x` command to restart the Kbox cloud phone container.<br><code>x</code> indicates the digit part of a container ID.<br>2. Run the `docker ps -a` command to check the Kbox cloud phone container that has been successfully restarted and its status.|
| Expected Result| 1. A message is displayed, indicating that the Kbox cloud phone container is successfully restarted.<br>2. The restarted device and its status are displayed.|
| Test Result|    |
| Remarks|    |

#### 4.1.3 Deleting a Kbox Cloud Phone Container<a name="ZH-CN_TOPIC_0000002518346234"></a>

<a name="table24712267"></a>

| Item| Description  |
|---|---|
| Case No.| 4.1.3 |
| Test Objective| Verify that a Kbox cloud phone container can be deleted.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Procedure| 1. Run the `./android11_kbox.sh delete x` command to delete the Kbox cloud phone container.<br><code>x</code> indicates the digit part of a container ID.<br>2. Run the `docker ps -a` command to query all Kbox cloud phone containers in the current environment.|
| Expected Result| 1. A message is displayed, indicating that the Kbox cloud phone container is successfully deleted.<br>2. The list of Kbox cloud phone containers does not contain the deleted Kbox cloud phone container.|
| Test Result|    |
| Remarks|    |

#### 4.1.4 Querying the Kbox Cloud Phone Container Status<a name="ZH-CN_TOPIC_0000002549826077"></a>

<a name="table35101782"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.4 |
| Test Objective| Verify that the Kbox cloud phone container status can be queried.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Procedure| 1. Run the `docker ps -a` command to query all Kbox cloud phone containers in the current environment.<br> 2. Run the `docker exec -it kbox_x sh` command to access the Kbox cloud phone container and then run the `getprop \| grep sys.boot_completed` command to query the container status.<br><code>x</code> indicates the digit part of a container ID.|
| Expected Result| 1. The device to be queried is displayed in the Kbox cloud phone list.<br>2. f the value of `[sys.boot_completed]` of the Kbox cloud phone to be queried is `[1]`, the Kbox cloud phone is successfully started.|
| Test Result|    |
| Remarks|    |

#### 4.1.5 Kbox Cloud Phone Container ADB Test<a name="ZH-CN_TOPIC_0000002549706085"></a>

<a name="table21405834"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.5 |
| Test Objective| Verify the connection and disconnection between the Kbox cloud phone container and the ADB.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Procedure| 1. Run the `adb connect [ip:port]` command to connect to a single container.<br>`ip:port` indicates the deployment IP address of the Kbox cloud phone and the port number of the started container, respectively. Replace them with the actual values.<br>2. Run the `adb disconnect [ip:port]` command to disconnect from a single container.|
| Expected Result| 1. If "connected to *ip:port*" is displayed in the command output, the ADB connection to the Kbox cloud phone container is successful.<br>2. If "disconnected *ip:port*" is displayed, the ADB disconnection from the Kbox cloud phone container is successful.|
| Test Result|    |
| Remarks|    |

#### 4.1.6 Resource Isolation Test<a name="ZH-CN_TOPIC_0000002518346226"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.6 |
| Test Objective| Verify that the resource isolation function of a Kbox cloud phone is normal.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.|
| Procedure|1. To verify the CPU resource isolation, run <code>docker exec -it kbox_x cat /proc/cpuinfo \| grep processor</code>. <br>2. To verify the memory resource isolation, run <code>docker exec -it kbox_x cat /proc/meminfo \| grep MemTotal</code>. <br>3. To verify the storage resource isolation, run <code>df -h \| grep -w kbox_x</code>. <br> <code>x</code> indicates the digit part of a container ID.|
| Expected Result| 1. The queried CPU core count of a single container matches the specifications in the feature guide.<br>2. The queried memory size of a single container matches the specifications in the feature guide.<br>3. The queried storage space of a single container matches the specifications in the feature guide.|
| Test Result|    |
| Remarks|    |

#### 4.1.7 GPS Mock Test<a name="ZH-CN_TOPIC_0000002549706077"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.7 |
| Test Objective| Verify the GPS mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.<br>3. Baidu Map or AMap has been installed in the container.|
| Procedure| 1. Use ARDC to connect to the Kbox cloud phone container and display the GUI.<br>2. Open Baidu Map or AMap to view your current location.|
| Expected Result| The current location is the preset mock location (Hangzhou Research Center of Huawei).|
| Test Result|    |
| Remarks|    |

#### 4.1.8 IMEI Mock Test<a name="ZH-CN_TOPIC_0000002518186306"></a>

<a name="table9347770"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.8 |
| Test Objective| Verify the IMEI mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br> 2. The Kbox cloud phone container has been created and connected via ARDC to display the cloud phone UI.|
| Procedure| 1. Enter `*#06#` on the dial-up screen of the cloud phone or run the `docker exec -it kbox_x getprop persist.sys.prop.writeimei` command on the server to query the IMEI.<br>2. On the server, run the `docker exec -it kbox_x sh setprop persist.sys.prop.writeimei imei_num` command to change the IMEI.<br>`x` indicates the digit part of a container ID.|
| Expected Result| 1. The IMEI preset in the Kbox cloud phone container is displayed.<br> 2. After the IMEI is changed on the server, the new IMEI is displayed in the query result.|
| Test Result|    |
| Remarks|    |

#### 4.1.9 Wi-Fi Mock Test<a name="ZH-CN_TOPIC_0000002549826083"></a>

<a name="table11771810"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.9 |
| Test Objective| Verify the Wi-Fi mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created.<br>3. AnTuTu has been installed on the Kbox cloud phone. (AnTuTu is used to activate the Wi-Fi mock function.)|
| Procedure| 1. Open AnTuTu and grant required permissions.<br>2. On the homepage, choose `My Device` > `Hardware` to view related configurations.|
| Expected Result| The Wi-Fi information is displayed under `Hardware`.|
| Test Result|    |
| Remarks|    |

#### 4.1.10 Sensor Mock Test<a name="ZH-CN_TOPIC_0000002518186312"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.10 |
| Test Objective| Verify the sensor (acceleration and gyroscope) mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.<br>3. AnTuTu has been installed on the Kbox cloud phone.|
| Procedure| On AnTuTu Benchmark, choose `My Device` > `Hardware` > `Sensors`.|
| Expected Result| `Acceleration Sensor` and `Gyroscope Sensor` are displayed under `Sensors`.|
| Test Result|    |
| Remarks|    |

#### 4.1.11 Creating a vinput Device<a id="creating-a-vinput-device"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.11 |
| Test Objective| Verify the function of creating a vinput device (mouse/handle).|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.|
| Procedure| 1. Open a remote server connection window A, and run the `docker exec -it kbox_x setprop persist.sys.input.[mouse/gamepad1/gamepad2].name xxx` command to set the names of the mouse, gamepad 1, and gamepad 2.<br>`x` indicates the digit part of a container ID, and `xxx` indicates a string of a maximum of 64 characters, containing letters, digits, and underscores (_).<br>2. After the setting is complete, run the `docker exec -it kbox_x getevent` command to query the configured device name.|
| Expected Result| 1. The device name is successfully set, and no error message is displayed.<br>2. The created device can be queried and the device name is correct.|
| Test Result|    |
| Remarks|    |

#### 4.1.12 Sending and Receiving vinput Device Events<a name="ZH-CN_TOPIC_0000002518186304"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.12 |
| Test Objective| Verify that a vinput device can properly send and receive events.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.|
| Procedure| 2. After setting [vinput devices](#creating-a-vinput-device), open another remote server connection window B and run the `getevent` command to listen to events.<br>2. In the remote connection window A, run the `docker exec -it kbox_x sh` command to access the container. Then run the `getevent -p` command to obtain the value of the `device`, `type`, `code`, and `value` parameters of an event.<br>3. Run the `sendevent [device] [type] [code] [value]` command in the container to send an event.<br><code>x</code> indicates the digit part of a container ID.|
| Expected Result| No error is reported when window A sends events, and window B can successfully listen to the events.|
| Test Result|    |
| Remarks|    |

#### 4.1.13 Modifying GPS Mock Properties<a name="ZH-CN_TOPIC_0000002518346228"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.13 |
| Test Objective| Verify that the GPS mock properties can be modified and queried.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.|
| Procedure| 1.<a id="step-1"></a>On the PC CLI, connect to the container, and run the `adb -s [ip:port] shell setprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed] xx` command to modify GPS properties.<br>`xx` indicates the valid value of each property. *ip:port* indicates the deployment IP address of the Kbox cloud phone and the port number of the started container, respectively. Replace them with the actual values.<br>2. On PC CLI, run the `adb -s [ip:port] shell getprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed]` command to query the values of GPS properties.|
| Expected Result| 1. No error message about a setting failure is displayed.<br>2. The GPS property values set in test step [1](#step-1) can be retrieved and the values are correct.|
| Test Result|    |
| Remarks|    |

#### 4.1.14 Setting Sensor Properties<a name="ZH-CN_TOPIC_0000002549706079"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.14 |
| Test Objective| Verify that the sensor mock properties on the three axes (x, y, and z) and data collection frequency properties can be modified.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.|
| Procedure| 1. On the PC CLI or the server CLI, run the `adb -s [ip:port] shell setprop persist.sensors.mock.[acce/gyro].data.[x/y/z] xx` command to modify the x-axis, y-axis, and z-axis parameters of the sensor. (*xx* can be any value within the range of ±3.402823466e+38. `acce` indicates the acceleration sensor, and `gyro` indicates the gyroscope sensor.)<br>2. Open `sensors_test.apk` and query the values of sensor properties.<br>3. On the PC CLI or the server CLI, run the `adb -s [ip:port] shell setprop persist.sensors.mock.delaytime xx` command (*xx* indicates any value in [20000,1000000]) to set the sensor mock data collection frequency.<br>4. Repeat steps 1 and 2.<br>5. Observe the change duration of the sensor properties after changing the data collection frequency.|
| Expected Result| 1. No error is reported during the setting.<br>2. The parameters are set successfully.<br>3. The parameters are queried successfully.<br>4. The change duration of the sensor properties vary according to the data collection frequency.|
| Test Result|    |
| Remarks|    |

#### 4.1.15 Querying the Kbox Component Version<a name="ZH-CN_TOPIC_0000002518346230"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.15 |
| Test Objective| Test the function of querying the Kbox component version.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.|
| Procedure| 1. Run the `sudo docker exec -it kbox_x sh` command to access the Kbox cloud phone container.<br> 2. Run the `cat /vendor/etc/kbox_version.txt` command to query the version information.|
| Expected Result| 1. The container is accessible.<br>2. The correct Kbox component version information is displayed as follows: (The specific version number is subject to the current version.)<br>Product Name: Kunpeng BoostKit<br>Product Version: xxx<br>Component Name: BoostKit-boostcph-kbox<br>Component Version: xxx<br>Component AppendInfo: 11.0.0_r48 |
| Test Result|    |
| Remarks|    |

#### 4.1.16 Testing the Hardware Decoding Video Playback Capability of the Kbox Cloud Phone<a name="ZH-CN_TOPIC_0000002518346232"></a>

<a name="table60533823"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.16 |
| Test Objective| Test the hardware decoding video playback capability of the Kbox cloud phone.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.<br> 3. Xplayer has been installed in the Kbox cloud phone container.<br>|
| Procedure| 1. Configure the Kbox cloud phone to use the hardware decoder of the NETINT T432/NETINT QUADRA T2A codec card according to the *Kbox Cloud Phone Container Feature Guide*.<br> 2. Import a video in 264_1280x720_30fps or 265_1280x720_30fps format into the container.<br> 3. Use XPlayer to play the imported video completely.|
| Expected Result| The video playback is normal without frame freezing or abnormal frames (such as artifact, black screen, and green screen). The hardware decoder name (OMX.media.video.decoder) can be queried in the log.|
| Test Result|    |
| Remarks|    |

#### 4.1.17 IMSI Mock Test<a name="ZH-CN_TOPIC_0000002549706081"></a>

<a name="table9347770"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.17 |
| Test Objective| Verify the IMSI mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. The Kbox cloud phone container has been created and connected via ARDC to display the cloud phone UI.|
| Procedure| 1. On the dial-up screen of the cloud phone, enter <code>*#*#4636#*#*</code> to query the IMSI.2. Run the `adb connect [ip:port]` command in the PC terminal window to connect to the specified container.<br>3. Run the `adb -s [ip:port] shell setprop persist.sys.prop.writeimsi xx` command in the PC terminal window, restart the Kbox cloud phone, and query the IMSI again.<br>*xx* indicates a valid IMSI.|
| Expected Result| 1. The preset IMSI of the Kbox cloud phone container (which is 46011 + random digits) is displayed.<br>2. After the IMSI is changed on the server, the new IMSI is displayed in the query result.|
| Test Result|    |
| Remarks|    |

#### 4.1.18 Querying Network Operator Information and SIM Card Information<a name="ZH-CN_TOPIC_0000002518186308"></a>

<a name="table9347770"></a>

| Item| Description|
|---|---|
| Case No.| 4.1.18 |
| Test Objective| Verify the function of querying network operator information and SIM card information.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. The Kbox cloud phone container has been created and connected via ARDC to display the cloud phone UI.<br>3. The `zausan.zdevicetest.apk` file has been installed in the Kbox cloud phone container.|
| Procedure| 1. Run the `sudo docker exec -it kbox_x sh` command on the server to access the Kbox cloud phone container.<br>2. Enter `dumpsys isub \| grep iccid` to query the serial number of the SIM card.<br>3. Open SSM/UMTS in `zausan.zdevicetest.apk` on the client.<br>4. View `SIM operator`, `SIM operator name`, `SIM country`, `Network operator`, `Network operator name`, `Network country`, and `Line one number`.<br>5. On the PC CLI, connect to the container, and run the `adb -s [ip:port] shell setprop persist.[sys.prop.writesimserial/gsm.sim.operator.alphacph/sys.prop.writeimsi/gsm.operator.numericcph/gsm.operator.alphacph/gsm.operator.numericcph/sys.prop.writephonenum] xx` command to modify the properties.<br>`xx` indicates the valid value of each property. *ip:port* indicates the deployment IP address of the Kbox cloud phone and the port number of the started container, respectively. Replace them with the actual values.<br>6. Restart the Kbox cloud phone and query the values again.|
| Expected Result| 1. The preset serial number of the SIM card in the Kbox cloud phone container (which is 898600 + random digits) is displayed.<br>2. The preset default initial values for SIM (operator, name, country) and Network (operator, name, country) are displayed as (46011, CMCC, cn) and (46000, CMCC, cn) respectively. The initial value of the `Line one number` is left blank by default.<br>3. The modified values of the Kbox cloud phone container are displayed.|
| Test Result|    |
| Remarks|    |

## 5 Test Result Analysis<a name="ZH-CN_TOPIC_0000002549826081"></a>

### 5.1 Basic Test Information<a name="ZH-CN_TOPIC_0000002518346222"></a>

<a name="table56604068"></a>

| Item| Description|
|---|---|
| Device manufacturer| &nbsp;&nbsp; |
| Device model| &nbsp;&nbsp; |
| Test location| &nbsp;&nbsp; |
| Tested by| &nbsp;&nbsp; |
| Test time| &nbsp;&nbsp; |
| Other| &nbsp;&nbsp; |

### 5.2 Test Result List<a name="ZH-CN_TOPIC_0000002549826079"></a>

|Test Type|Case No.|Case Name|Test Result (PASS/FAIL/NT)|
|--|--|--|--|
|Basic function tests|4.1.1|Creating a Kbox cloud phone container|
||4.1.2|Restarting a Kbox cloud phone container|
||4.1.3|Deleting a Kbox cloud phone container|
||4.1.4|Querying the Kbox cloud phone container status|
||4.1.5|Kbox cloud phone container ADB test|
||4.1.6|Resource isolation test|
||4.1.7|GPS Mock Test|
||4.1.8|IMEI mock test|
||4.1.9|Wi-Fi mock test|
||4.1.10|Sensor mock test|
||4.1.11|Creating a vinput device|
||4.1.12|Sending and receiving vinput device events|
||4.1.13|Modifying GPS mock properties|
||4.1.14|Setting Sensor Properties|
||4.1.15|Querying the Kbox component version|
||4.1.16|Testing the hardware decoding video playback capability of the Kbox cloud phone|
||4.1.17|IMSI Mock Test|
||4.1.18|Querying network operator information and SIM card information|

## 6 Customer Suggestions and Result Confirmation<a name="ZH-CN_TOPIC_0000002549826075"></a>

### 6.1 Customer Suggestions<a name="ZH-CN_TOPIC_0000002549706083"></a>

### 6.2 Result Confirmation<a name="ZH-CN_TOPIC_0000002549826073"></a>

|Tested Party: Huawei Technologies Co., Ltd.|Testing Party:|
|--|--|
|Test Personnel Signature:|Test Personnel Signature:|
|Date:|Date:|
