# Garmin Kayak Stroke

A Connect IQ watch app for the Garmin Forerunner 970. While open, it displays an experimental accelerometer-based kayak stroke count, strokes per minute, and elapsed time.

## Watch controls

- **SELECT**: start, pause, or resume a session.
- **BACK**: stop the current session. Starting again begins a fresh session.
- **MENU** while paused or stopped: reset the displayed session counters.

## Build and install

1. Install Garmin Connect IQ SDK Manager and the Monkey C extension for Visual Studio Code.
2. Install an SDK version that includes the Forerunner 970 and open this repository in VS Code.
3. Select **Forerunner 970** as the target device.
4. Build and test in the Connect IQ simulator first, including sensor data and button behavior.
5. For a physical watch, register it as a development device and deploy using the VS Code Run/Debug flow. A development build is not a Garmin Connect IQ Store release.

## Limitations

- Stroke detection is a simple motion-change heuristic, not a trained or validated model. Waves, handling, mounting position, and vibration can cause false positives or missed strokes. Test and calibrate safely.
- The app currently displays counters only; it does not create or save a Garmin FIT activity.
- It does not measure watts. Reliable power requires a compatible power sensor.
- Validate the APIs and behavior against the installed Garmin SDK and the actual Forerunner 970 before relying on the app during training.
