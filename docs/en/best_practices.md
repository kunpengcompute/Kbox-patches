# Best Practices<a name="ZH-CN_TOPIC_0000002521463656"></a>

## Practice 1: Enabling Adaptive Vsync to Reduce E2E Operation Latency<a name="ZH-CN_TOPIC_0000002549833663"></a>

### Overview

The end-to-end (E2E) operation latency of cloud phones and cloud gaming is a critical factor determining user experience. BoostKit Kbox provides the adaptive vertical synchronization (vsync) feature to optimize the vsync mechanism of the Android graphics subsystem on the server, thereby reducing the latency during the rendering and frame-capture stages. It has been verified that this feature effectively reduces E2E operation latency in mainstream gaming scenarios.

#### Recommended Version

BoostKit Kbox 7.2.RC1 or later

### Environment Setup

This practice requires the deployment of both a cloud phone server and client to ensure normal streaming of the cloud phone.

1. Deploy a video stream cloud phone (7.2.RC1 or later) by referring to the *Deployment and Installation Guide*.
2. Install a streaming client on the phone or use other streaming methods to ensure successful streaming and cloud phone control.

**Since network transmission latency has a significant impact on E2E latency, you are advised to ensure a stable network connection for cloud phone streaming. This guarantees stable E2E latency measurements in the following steps and allows for an accurate comparison of optimization effects.**

### Feature Enablement

1. `cd /home/kbox_video`
2. `docker cp android_1:/system/vendor/build.prop .`
3. `echo "ro.vmi.adaptive.vsync=1" >> build.prop`
4. `docker cp build.prop android_1:/system/vendor/build.prop`
5. `./cfct_video restart 1`
6. Check whether "`Enabling adaptive vsync.`" is displayed in the logcat log. If yes, adaptive vsync is enabled.

> Note:
>
> 1. *android_1* is a sample cloud phone container name. Adjust it based on your actual environment.
> 2. The adaptive vsync feature is enabled when **ro.vmi.adaptive.vsync** is set to **1**. You can also use other methods (such as specifying this property value when compiling the Android image) to make it take effect upon container startup.

### Verification

1. Deploy a video stream cloud phone by referring to sections "Environment Setup" and "Feature Enablement".
2. Enable the crosshair cursor display on the phone (ensure that the crosshair appears on the local screen upon tapping). Run a common game application, such as Genshin Impact, and remain stationary at a fixed position after entering the game.
3. Enable cloud phone streaming.
4. Prepare a stopwatch (or run the stopwatch application on another phone) and start timing.
5. Use a recording device that supports 120/240 fps to simultaneously record the streaming phone screen and the stopwatch. Ensure that both the phone screen and the stopwatch clock are unobstructed in the video.
6. Quickly tap the game button multiple times with a 5-second interval between taps. Stop the recording after completing the taps.
7. In the recorded video, determine the time interval from the time when the crosshair appears (indicating a tap) to the time when the on-screen button responds. Record this interval as the tap latency. Calculate the average latency of multiple taps.
8. Enable adaptive vsync, repeat steps 2 to 7, and record the average tap latency after adaptive vsync takes effect.
9. Compare the average tap latency before and after adaptive vsync is enabled to observe its optimization effect on E2E latency.
