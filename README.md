# Garmin Kayak Analytics (prototype)

A Connect IQ watch app for a Forerunner 970 mounted to the kayak. It analyzes the movement measured at the boat mount, rather than assuming the watch is worn on the paddler's wrist.

## Current prototype metrics

- Experimental stroke count and live strokes per minute.
- Session-average strokes per minute and elapsed time.
- A rolling estimate of acceleration along the mount's learned gravity axis, plus its recent range. These are acceleration diagnostics, **not measured hull displacement or wave height**.
- The detector learns a slow gravity baseline and background motion threshold, with hysteresis and a refractory period to reduce duplicate counts.

## Controls

- **SELECT**: start, pause, or resume.
- **BACK**: stop the current counter session; the summary remains visible until a new session starts.
- **MENU** while paused/stopped: reset the displayed session metrics.

## Important constraints

- Mounting the watch on the boat changes the signal substantially. Hull motion, waves, mounting stiffness, sensor orientation, and paddle technique can cause false or missed strokes. The current algorithm is a starting point for on-water validation, not a validated kayak measurement model.
- The accelerometer can measure acceleration, but it cannot directly measure paddle force. This app therefore does **not** invent a watt value. Real power needs a compatible force/power sensor; any speed-and-motion-only output would have to be explicitly labeled as an estimate and calibrated against real measurements.
- A Connect IQ data field can integrate with Garmin's native activity recording, but raw sensor streaming is restricted for data fields. This project remains a standalone watch app so it can access the boat-mounted accelerometer. It does not yet create a native Garmin activity/FIT file or trigger Garmin's post-activity rating flow.
- The current `period => 1` sensor configuration and sensor availability must be confirmed against the installed SDK/device. A low-rate sample stream is not sufficient for reliable stroke-shape or wave analysis.

## Long-term development path

1. Validate sensor sample rate, axis units, and mounting orientation on the Forerunner 970.
2. Add a guided calibration and a boat-mount profile; capture labeled sessions (including missed/false strokes) to tune thresholds.
3. Evaluate cadence and boat-motion signals against video or a trusted paddle sensor, and add confidence/quality indicators before claiming accuracy.
4. Add FIT activity recording and post-session summaries only after validating the supported Connect IQ recording APIs on the target watch.
5. Investigate power integration with a real compatible sensor. Any model-based power estimate should be clearly separated from measured watts.

A future adaptive model needs representative, user-consented labeled data and validation. The app cannot reliably “learn by itself” from unlabeled noisy motion alone; improvements should be tested against known stroke counts and sensor references.

## Build and test

1. Install Garmin Connect IQ SDK Manager and the Monkey C extension for Visual Studio Code.
2. Install an SDK that includes the Forerunner 970, open the repository, and select the watch as the target.
3. Build and test in the simulator, then test on the boat mount in safe, calm conditions against a manually counted session.
4. Record false positives, missed strokes, mounting orientation, and sensor behavior before tuning thresholds. This prototype is not a safety or navigation device.
