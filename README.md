# Garmin Kayak Stroke (prototype)

A small Connect IQ watch-app prototype targeting the Garmin Forerunner 970. It displays an experimental accelerometer-based stroke count, strokes per minute, and elapsed time. The watch should be secured to the kayak in a consistent orientation.

## Current prototype limitations

- Stroke detection is a simple motion-change threshold, not a trained or validated model. Expect false positives/negatives from waves, handling, and mount vibration. Calibrate and test safely before relying on it.
- It does not yet create/save a Garmin FIT activity. It only displays the counters while the app is open.
- It does not measure watts. Accurate power requires a compatible power sensor; acceleration alone cannot provide reliable kayak power.
- The 970's exact Connect IQ API/device support and the APIs used here must be validated against the installed Garmin SDK. This repository is a starting prototype, not a verified release build.

## Build and install

1. Install Garmin Connect IQ SDK Manager and the Monkey C extension for Visual Studio Code from Garmin's official developer site.
2. Install a Connect IQ SDK version that includes the Forerunner 970, then open this repository folder in VS Code.
3. Select the Forerunner 970 as the target device in the Monkey C project settings.
4. Build and launch in the simulator first. Confirm the sensor callback and app keys work with the installed SDK/device profile.
5. For a physical watch, use Garmin's development-device setup and VS Code's Run/Debug deployment flow. The watch must be registered as a development device; a sideloaded development app is not the same as a Connect IQ Store installation.

Typical VS Code commands are available from the Command Palette: **Monkey C: Build for Device** and **Monkey C: Run**. Exact labels can vary by extension version. For Store distribution, create a developer account, sign and submit the app through Garmin's Connect IQ developer portal; approval is separate from local installation.

## First-use test

Open the app and press **SELECT** to start/stop counting. Keep the watch mounted on the kayak and test a known number of strokes in calm conditions. Compare the displayed count and cadence with a manual count. Do not treat this threshold algorithm as automatically trained: this prototype has no calibration/training workflow yet.
