# Acceptance Test Guide<a name="ZH-CN_TOPIC_0000002552775781"></a>

## 1 Overview<a name="ZH-CN_TOPIC_0000002518186290"></a>

### 1.1 Acceptance Criteria<a name="ZH-CN_TOPIC_0000002518346216"></a>

This document provides guidance for accepting cloud phone products. Before the acceptance, ensure that the physical environment, system environment, and software version are correct. The test cases in this document are designed by the cloud phone product test team, covering the basic functions of the Kbox cloud phone.

### 1.2 Precautions<a name="ZH-CN_TOPIC_0000002518346214"></a>

1. Before the acceptance, ensure that the physical environment, system environment, and software version are correct and matched.
2. Before executing the acceptance test cases, deploy the end-to-end Kbox cloud phone environment. For details, see [Installation Guide](install_guide.md).
3. Ensure that the acceptance items are confirmed by Huawei and the customer.
4. During the product acceptance and preliminary acceptance tests, both parties should strictly observe applicable test criteria. Because some items have been tested before delivery, you can sample or omit such items if the site conditions are not appropriate.

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>In the acceptance tests, abide by the contract and agreements between both parties. This document is for reference only.

## 2 Preparations<a name="ZH-CN_TOPIC_0000002549826063"></a>

For details about the server hardware and software package information, environment deployment before test case acceptance, and density test method, see [Installation Guide](install_guide.md). For details about the BIOS, iBMC, and CPLD versions, see [Release Notes](release_notes.md).

## 3 Test Conventions<a name="ZH-CN_TOPIC_0000002549706061"></a>

**Result Description<a name="section62693428"></a>**

The test results are defined as follows:

- **PASS**: The test result is consistent with the expected result after a test is performed based on the prerequisites and preset procedure.
- **FAIL**: The test result is inconsistent with the expected result after a test is performed based on the prerequisites and preset procedure.
- **NT**: The test is not implemented because the requirements have changed or the test environment does not meet the requirements.

## 4 Test Cases and Test Records<a name="ZH-CN_TOPIC_0000002518186282"></a>

### 4.1 Basic Function Tests<a name="ZH-CN_TOPIC_0000002549706067"></a>

#### 4.1.1 Creating a Kbox Cloud Phone Container<a name="ZH-CN_TOPIC_0000002518186286"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.1 |
| Test Objective| Verify that a Kbox cloud phone container can be created.|
| Test Networking| None|
| Prerequisites| The basic environment of the Kbox cloud phone has been deployed.|
| Procedure| 1. Run the `./android_kbox_aosp15.sh start kbox_image:tag <x> <y>` command to create Kbox cloud phone containers.<br> Note:<br> *x* and *y* indicate the start and end IDs of containers to be created, respectively. For example, to create containers 1 to 9, enter **1** for *x* and **9** for *y*. To create only one container, enter a value for *x* only.<br>2. Run the `docker ps -a` command to view the created Kbox cloud phone container and its status.|
| Expected Result| 1. A message is displayed, indicating that the Kbox cloud phone container is successfully created.<br>2. The created device and its status are displayed.|
| Test Result|   |
| Remarks|   |

#### 4.1.2 Restarting a Kbox Cloud Phone Container<a name="ZH-CN_TOPIC_0000002518346212"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.2 |
| Test Objective| Verify that a Kbox cloud phone container can be restarted.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Procedure| 1. Run the `./android_kbox_aosp15.sh restart <x>` command to restart the Kbox cloud phone container.<br> Note:<br> *x* indicates the digit part of a container ID.<br>2. Run the `docker ps -a` command to check the Kbox cloud phone container that has been successfully restarted and its status.|
| Expected Result| 1. A message is displayed, indicating that the Kbox cloud phone container is successfully restarted.<br>2. The restarted device and its status are displayed.|
| Test Result|  |
| Remarks|  |

#### 4.1.3 Deleting a Kbox Cloud Phone Container<a name="ZH-CN_TOPIC_0000002549706073"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.3 |
| Test Objective| Verify that a Kbox cloud phone container can be deleted.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Procedure| 1. Run the `./android_kbox_aosp15.sh delete <x>` command to delete the Kbox cloud phone container.<br>Note:<br> *x* indicates the digit part of a container ID.<br>2. Run the `docker ps -a` command to query all Kbox cloud phone containers in the current environment.|
| Expected Result| 1. A message is displayed, indicating that the Kbox cloud phone container is successfully deleted.<br>2. The list of Kbox cloud phone containers does not contain the deleted Kbox cloud phone container.|
| Test Result|  |
| Remarks|  |

#### 4.1.4 Querying the Kbox Cloud Phone Container Status<a name="ZH-CN_TOPIC_0000002549706071"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.4 |
| Test Objective| Verify that the Kbox cloud phone container status can be queried.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Procedure| 1. Run the `docker ps -a` command to query all Kbox cloud phone containers in the current environment.<br> 2. Run the `docker exec -it kbox_<x> sh` command to access the Kbox cloud phone container and then run the `getprop \| grep sys.boot_completed` command to query the running status of the container.<br> Note:<br> *x* indicates the digit part of a container ID.|
| Expected Result| 1. The device to be queried is displayed in the Kbox cloud phone list.<br>2. If the value of `sys.boot_completed` of the Kbox cloud phone to be queried is **[1]**, the Kbox cloud phone is successfully started.|
| Test Result|  |
| Remarks|  |

#### 4.1.5 Kbox Cloud Phone Container ADB Test<a name="ZH-CN_TOPIC_0000002549826069"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.5 |
| Test Objective| Verify the connection and disconnection between the Kbox cloud phone container and the ADB.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been started.|
| Procedure| 1. Run the `adb connect ip:port` command to connect to a single container.<br> Note:<br> *ip:port* indicates the deployment IP address of the Kbox cloud phone and the port number of the started container, respectively.<br>2. Run the `adb disconnect ip:port` command to disconnect from a single container.|
| Expected Result| 1. If "connected to *ip:port*" is displayed in the command output, the ADB connection to the Kbox cloud phone container is successful.<br>2. If "disconnected *ip:port*" is displayed, the ADB disconnection from the Kbox cloud phone container is successful.|
| Test Result|  |
| Remarks|  |

#### 4.1.6 Resource Isolation Test<a name="ZH-CN_TOPIC_0000002518186296"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.6 |
| Test Objective| Verify that the resource isolation function of a Kbox cloud phone is normal.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.|
| Procedure| 1. Run the `docker exec -it kbox_<x> cat /proc/cpuinfo \| grep processor` command to verify CPU resource isolation.<br>2. Run the `docker exec -it kbox_<x> cat /proc/meminfo \| grep MemTotal` command to verify memory resource isolation.<br>3. Run the `df -h \| grep -w kbox_<x>` command to verify storage resource isolation.<br> Note:<br> *x* indicates the digit part of a container ID.|
| Expected Result| 1. The queried CPU core count of a single container matches the specifications in the feature guide.<br>2. The queried memory size of a single container matches the specifications in the feature guide.<br>3. The queried storage space of a single container matches the specifications in the feature guide.|
| Test Result|  |
| Remarks|  |

#### 4.1.7 GPS Mock Test<a name="ZH-CN_TOPIC_0000002549826053"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.7 |
| Test Objective| Verify the GPS mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.<br>3. Baidu Map or AMap has been installed in the container.|
| Procedure| 1. Connect SCRCPY with the Kbox cloud phone container to display the UI.<br>2. Open Baidu Map or AMap to view your current location.|
| Expected Result| The current location is the preset mock location (Hangzhou Research Center of Huawei).|
| Test Result|  |
| Remarks|  |

#### 4.1.8 IMEI Mock Test<a name="ZH-CN_TOPIC_0000002518186292"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.8 |
| Test Objective| Verify the IMEI mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. The Kbox cloud phone container has been created and connected to SCRCPY to display the cloud phone UI.|
| Procedure| 1. Enter `*#06#` on the dialing screen of the cloud phone.<br>2. Run the `docker exec -it kbox_<x> setprop persist.sys.prop.writeimei imei_num` command on the server to change the IMEI. The new IMEI must be a valid 15-digit number. Restart the Kbox cloud phone and query the IMEI again.<br>3. After the property setting is complete, run the `docker exec -it kbox_<x> getprop persist.sys.prop.writeimei` command on the server to query the IMEI.<br> Note:<br> *x* indicates the digit part of a container ID.|
| Expected Result| 1. The IMEI preset in the Kbox cloud phone container is displayed.<br>2. After the IMEI is changed on the server, the new IMEI is displayed in the query result.|
| Test Result|  |
| Remarks|  |

#### 4.1.9 Wi-Fi Mock Test<a name="ZH-CN_TOPIC_0000002518346202"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.9 |
| Test Objective| Verify the Wi-Fi mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created.<br>3. AnTuTu has been installed on the Kbox cloud phone. (AnTuTu is used to activate the Wi-Fi mock function.)|
| Procedure| 1. Open AnTuTu and grant required permissions.<br>2. On the homepage, choose **My Device** > **Hardware** to view related configurations.|
| Expected Result| The Wi-Fi information is displayed under **Hardware**.|
| Test Result|  |
| Remarks|  |

#### 4.1.10 Sensor Mock Test<a name="ZH-CN_TOPIC_0000002549706057"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.10 |
| Test Objective| Verify the sensor (acceleration and gyroscope) mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.<br>3. AnTuTu has been installed on the Kbox cloud phone.|
| Procedure| On AnTuTu Benchmark, choose **My Device** > **Hardware** > **Sensors**.|
| Expected Result| **Acceleration Sensor** and **Gyroscope Sensor** are displayed under **Sensors**.|
| Test Result|  |
| Remarks|  |

#### 4.1.11 Creating a vinput Device<a name="creating-a-vinput-device"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.11 |
| Test Objective| Verify the function of creating a vinput device (mouse/handle).|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.|
| Procedure| 1. Open a remote server connection window A, and run the `docker exec -it kbox_<x> setprop persist.sys.input.[mouse/gamepad1/gamepad2].name <xxx>` command to set the names of the mouse, gamepad 1, and gamepad 2.<br> Note:<br> *x* indicates the digit part of a container ID, and *xxx* indicates a string of a maximum of 64 characters, containing letters, digits, and underscores (_).<br>2. After the setting is complete, run the `docker exec -it kbox_<x> getevent` command to query the configured device name.|
| Expected Result| 1. The device name is successfully created, and no error message is displayed.<br>2. The created device can be queried and the device name is correct.|
| Test Result|  |
| Remarks|  |

#### 4.1.12 Sending and Receiving vinput Device Events<a name="ZH-CN_TOPIC_0000002518186288"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.12 |
| Test Objective| Verify that a vinput device can properly send and receive events.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.|
| Procedure| 1. After the settings in [4.1.11-Creating a vinput Device](#creating-a-vinput-device) are complete, open another remote server connection window B and run the `getevent` command to listen to events.<br>2. In window A, run the `docker exec -it kbox_<x> sh` command to access the container, and then run the `getevent -p` command to obtain the value of [device], [type], [code], and [value] of the corresponding event.<br>3. Run the `sendevent [device] [type] [code] [value]` command in the container to send an event.<br> Note:<br> *x* indicates the digit part of a container ID.|
| Expected Result| No error is reported when window A sends events, and window B can successfully listen to the events.|
| Test Result|  |
| Remarks|  |

#### 4.1.13 Modifying GPS Mock Properties<a name="ZH-CN_TOPIC_0000002549826067"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.13 |
| Test Objective| Verify that the GPS mock properties can be modified and queried.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected.|
| Procedure| 1. At the PC command prompt, connect to the container, and run the `adb -s <ip:port> shell setprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed] <xx>` command to modify GPS properties.<br> Note:<br> *xx* indicates a valid value of a property. *ip:port* indicates the deployment IP address of the Kbox cloud phone and the port number of the started container, respectively.<br>2. At the PC command prompt, run the `adb -s <ip:port> shell getprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed]` command to query the values of GPS properties.|
| Expected Result| 1. No error message about a setting failure is displayed.<br>2. The GPS properties set in step 1 can be queried and the values are correct.|
| Test Result|  |
| Remarks|  |

#### 4.1.14 Setting Sensor Properties<a name="ZH-CN_TOPIC_0000002549826059"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.14 |
| Test Objective| Verify that the sensor mock properties on the three axes (x, y, and z) and data collection frequency properties can be modified.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.|
| Procedure| 1. At the PC command prompt or on the server, run the `adb -s [ip:port] shell setprop persist.sensors.mock.[acce/gyro].data.[x/y/z] <xx>` command to modify the x-axis, y-axis, and z-axis parameters of the sensor. (*xx* can be any value within the range of ±3.402823466e+38. **acce** indicates the acceleration sensor and **gyro** indicates the gyroscope.)<br>2. Open **sensors_test.apk** and query the values of sensor properties.<br>3. At the PC command prompt or on the server, run the `adb -s [ip:port] shell setprop persist.sensors.mock.delaytime xx` command (*xx* indicates any value in [20000,1000000]) to set the sensor mock data collection frequency.<br>4. Repeat steps 1 and 2.<br>5. Observe the change duration of the sensor properties after changing the data collection frequency.|
| Expected Result| 1. No error is reported during the setting.<br>2. The parameters are set successfully.<br>3. The parameters are queried successfully.<br>4. The change duration of the sensor properties vary according to the data collection frequency.|
| Test Result|  |
| Remarks|  |

#### 4.1.15 Querying the Kbox Component Version<a name="ZH-CN_TOPIC_0000002549826061"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.15 |
| Test Objective| Test the function of querying the Kbox component version.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.|
| Procedure| 1. Run the `sudo docker exec -it kbox_<x> sh` command to access the Kbox cloud phone container.<br>2. Run the `cat /vendor/etc/kbox_version.txt` command to query the version information.|
| Expected Result| 1. The container can be accessed.<br>2. The correct Kbox component version information is displayed as follows: (The specific version number is subject to the current version.)<br>Product Name: Kunpeng BoostKit<br>Product Version: xxx<br>Component Name: BoostKit-boostcph-kbox<br>Component Version: xxx<br>Component AppendInfo: 15.0.0_r17 |
| Test Result|  |
| Remarks|  |

#### 4.1.16 Testing the Hardware Decoding Video Playback Capability of the Kbox Cloud Phone<a name="ZH-CN_TOPIC_0000002549826065"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.16 |
| Test Objective| Test the hardware decoding video playback capability of the Kbox cloud phone.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. A Kbox cloud phone container has been created and connected via the ADB.<br>3. Xplayer has been installed in the Kbox cloud phone container.|
| Procedure| 1. Configure the Kbox cloud phone to use the hardware decoder of NETINT QUADRA T2A according to the *Feature Guide*.<br>2. Import a video in 264_1280x720_30fps or 265_1280x720_30fps format into the container.<br>3. Use XPlayer to play the imported video completely.|
| Expected Result| 1. The video playback is normal without frame freezing or abnormal frames (such as artifact, black screen, and green screen). The hardware decoder name (OMX.media.video.decoder) can be queried in the log.|
| Test Result|  |
| Remarks|  |

#### 4.1.17 IMSI Mock Test<a name="ZH-CN_TOPIC_0000002518186300"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.17 |
| Test Objective| Verify the IMSI mock function.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. The Kbox cloud phone container has been created and connected to SCRCPY to display the cloud phone UI.|
| Procedure| 1. On the dial-up screen of the cloud phone, enter `*#*#4636#*#*` to query the IMSI.<br>2. Run the `adb connect [ip:port]` command in the PC terminal window to connect to the specified container.<br>3. Run the `adb -s [ip:port] shell setprop persist.sys.prop.writeimsi xx` command in the PC terminal window, restart the Kbox cloud phone, and query the IMSI again.<br> Note:<br> *xx* indicates a valid IMSI.|
| Expected Result| 1. The preset IMSI of the Kbox cloud phone container (which is 46011 + a random 10-digit number) is displayed.<br>2. After the IMSI is changed on the server, the new IMSI is queried, containing 15 digits.|
| Test Result|  |
| Remarks|  |

#### 4.1.18 Querying Network Operator Information and SIM Card Information<a name="ZH-CN_TOPIC_0000002518186284"></a>

| Project| Content|
| --- | --- |
| Case No.| 4.1.18 |
| Test Objective| Verify the function of querying network operator information and SIM card information.|
| Test Networking| None|
| Prerequisites| 1. The basic environment of the Kbox cloud phone has been deployed.<br>2. The Kbox cloud phone container has been created and connected to SCRCPY to display the cloud phone UI.<br>3. The **zausan.zdevicetest.apk** file has been installed in the Kbox cloud phone container.|
| Procedure| 1. Run the `sudo docker exec -it kbox_<x> sh` command on the server to access the Kbox cloud phone container.<br>2. Enter `dumpsys isub \| grep -i iccid` to query the integrated circuit card identifier (ICCID) of the SIM card.<br>3. Open SSM/UMTS in **zausan.zdevicetest.apk** on the client.<br>4. View **SIM operator**, **SIM operator name**, **SIM country**, **Network operator**, **Network operator name**, **Network country**, and **Line one number**.<br>5. At the PC command prompt, connect to the container, and run the `adb -s [ip:port] shell setprop persist.[sys.prop.writesimserial/gsm.sim.operator.alphacph/sys.prop.writeimsi/gsm.operator.numericcph/gsm.operator.alphacph/gsm.operator.numericcph/sys.prop.writephonenum] <xx>` command to modify the properties.<br> Note:<br> *xx* indicates a valid value of a property. *ip:port* indicates the deployment IP address of the Kbox cloud phone and the port number of the started container, respectively.<br>6. Restart the Kbox cloud phone and query the values again.|
| Expected Result| 1. The preset ICCID of the SIM card (898600 + random digits + [****]) in the Kbox cloud phone container is displayed.<br>2. The properties preset in the Kbox cloud phone container and their related default initial values are as follows: SIM operator: 46011; SIM operator name: CMCC; SIM country: cn; Network operator: 46000; Network operator name: CMCC; Network country: cn; Line one number: empty.<br>3. The modified values of the Kbox cloud phone container are displayed.|
| Test Result|  |
| Remarks|  |

## 5 Test Result Analysis<a name="ZH-CN_TOPIC_0000002518346204"></a>

### 5.1 Basic Test Information<a name="ZH-CN_TOPIC_0000002518186298"></a>

| Project| Content|
| --- | --- |
| Device Manufacturer|  |
| Device Model|  |
| Test Location|  |
| Test Personnel|  |
| Test Time|  |
| Other Information|  |

### 5.2 Test Result List<a name="ZH-CN_TOPIC_0000002549706059"></a>

**Table 1** Basic function tests<a id="basic-function-tests"></a>

|Test Type|Case No.|Case Name|Test Result (PASS/FAIL/NT)|
|--|--|--|--|
|Basic function tests|4.1.1|Creating a Kbox Cloud Phone Container|
|Basic function tests|4.1.2|Restarting a Kbox Cloud Phone Container|
|Basic function tests|4.1.3|Deleting a Kbox Cloud Phone Container|
|Basic function tests|4.1.4|Querying the Kbox Cloud Phone Container Status|
|Basic function tests|4.1.5|Kbox Cloud Phone Container ADB Test|
|Basic function tests|4.1.6|Resource Isolation Test|
|Basic function tests|4.1.7|GPS Mock Test|
|Basic function tests|4.1.8|IMEI Mock Test|
|Basic function tests|4.1.9|Wi-Fi Mock Test|
|Basic function tests|4.1.10|Sensor Mock Test|
|Basic function tests|4.1.11|Creating a Vinput Device|
|Basic function tests|4.1.12|Sending and Receiving Vinput Device Events|
|Basic function tests|4.1.13|Modifying GPS Mock Properties|
|Basic function tests|4.1.14|Setting Sensor Properties|
|Basic function tests|4.1.15|Querying the Kbox Component Version|
|Basic function tests|4.1.16|Testing the Hardware Decoding Video Playback Capability of the Kbox Cloud Phone|
|Basic function tests|4.1.17|IMSI Mock Test|
|Basic function tests|4.1.18|Querying Network Operator Information and SIM Card Information|

## 6 Customer Suggestions and Result Confirmation<a name="ZH-CN_TOPIC_0000002549706063"></a>

### 6.1 Customer Suggestions<a name="ZH-CN_TOPIC_0000002549826055"></a>

### 6.2 Result Confirmation<a name="ZH-CN_TOPIC_0000002518346208"></a>

|Tested Party: Huawei Technologies Co., Ltd.|Testing Party:|
|--|--|
|Test Personnel Signature:|Test Personnel Signature:|
|Time:|Time:|
