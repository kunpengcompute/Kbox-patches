# Best Practices<a name="ZH-CN_TOPIC_0000002521463656"></a>

## Practice 1: Enabling Adaptive Vsync to Reduce the E2E Operation Latency<a name="ZH-CN_TOPIC_0000002549833663"></a>

### Introduction

The end-to-end (E2E) operation latency of cloud phones and cloud gaming is a critical factor determining user experience. The BoostKit Kbox component provides the adaptive Vsync feature to optimize the Vsync mechanism of the Android graphics subsystem on the server, thereby reducing the latency during the rendering and capturing stage. Verification shows that this feature effectively reduces E2E operation latency in mainstream gaming scenarios.

#### Recommended Version

BoostKit Kbox 7.2.RC1 or later

### Environment Setup

This practice requires the deployment of both the cloud phone server and client to ensure normal stream output from the cloud phone.

1. Deploy the video-streaming cloud phone (7.2.RC1 or later) by following the _Deployment and Installation_ Guide.
2. Install the streaming client on a mobile phone or use other streaming methods to ensure normal stream output and cloud phone operation.

**The Network transmission latency heavily impacts E2E latency. To ensure stable E2E latency measurement and accurate comparison of optimization effects in the following steps, ensure a stable network connection for the cloud phone stream output.**

### Feature Enablement

1. `cd /home/kbox_video`
2. `docker cp android_1:/system/vendor/build.prop .`
3. `echo "ro.vmi.adaptive.vsync=1" >> build.prop`
4. `docker cp build.prop android_1:/system/vendor/build.prop`
5. `./cfct_video restart 1`
6. Check whether "`Enabling adaptive vsync.`" is printed in the logcat logs. If it is, adaptive Vsync has been successfully enabled.

> Note:
>
> 1. `android_1` is a sample cloud phone container name. Adjust it based on your actual environment.
> 2. The adaptive Vsync feature is enabled when `ro.vmi.adaptive.vsync` is set to `1`. You can also use other methods (such as specifying this property value when compiling the Android image) to make it take effect upon container startup.

### Verification

1. Deploy the video-streaming cloud phone by following the instructions in the "Environment Setup" and "Feature Enablement" sections.
2. Enable the crosshair cursor display on the phone (ensure that the crosshair appears on the local screen upon tapping). Run a common game application, such as Genshin Impact, and remain stationary at a fixed position after entering the game.
3. Start cloud phone stream output.
4. Prepare a stopwatch (or use a stopwatch app on another phone) and start timing.
5. Use a recording device that supports 120/240 fps to simultaneously record the streaming phone screen and the stopwatch. Ensure that both the phone screen and the stopwatch clock are unobstructed in the video.
6. Quickly click the in-game button multiple times with a 5-second interval between clicks. Stop recording after completing the clicks.
7. In the recorded video, determine the time interval from the time when the crosshair appears (indicating a tap) to the time when the on-screen button responds. Record this interval as the tap latency. Calculate the average latency across multiple clicks.
8. Repeat steps 2 to 7 after enabling adaptive Vsync, and record the average tap latency with adaptive Vsync active.
9. Compare the average tap latency measured before and after enabling adaptive Vsync to observe its optimization effect on E2E latency.
