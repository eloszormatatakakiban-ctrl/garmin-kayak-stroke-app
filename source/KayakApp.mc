using Toybox.Application;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class KayakApp extends Application.AppBase {
    var _timer;

    function initialize() {
        AppBase.initialize();
        KayakState.reset();
    }

    function getInitialView() {
        return [new KayakView(), new KayakDelegate()];
    }

    function onStart(state) {
        KayakState.running = false;
        KayakState.resetDetector();
        KayakState.sensorAvailable = true;

        try {
            Sensor.registerSensorDataListener(method(:onSensorData), {
                :period => 1,
                :accelerometer => true
            });
        } catch (e) {
            KayakState.sensorAvailable = false;
        }

        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 1000, true);
    }

    function onStop(state) {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        try {
            Sensor.unregisterSensorDataListener();
        } catch (e) {
            // The listener may not have registered on devices without sensor support.
        }
    }

    function onTick() {
        if (KayakState.running) {
            KayakState.elapsedSeconds += 1;
        }
        WatchUi.requestUpdate();
    }

    function onSensorData(data) {
        if (!KayakState.running || data == null || data.accel == null) {
            return;
        }

        var acceleration = data.accel;
        if (acceleration.size() < 3) {
            return;
        }

        // Magnitude makes the detector less sensitive to watch orientation.
        var magnitude = Math.sqrt(
            (acceleration[0] * acceleration[0]) +
            (acceleration[1] * acceleration[1]) +
            (acceleration[2] * acceleration[2])
        );

        // The first sample after start/resume is only a baseline, not a stroke.
        if (!KayakState.hasMagnitude) {
            KayakState.lastMagnitude = magnitude;
            KayakState.hasMagnitude = true;
            return;
        }

        var delta = magnitude - KayakState.lastMagnitude;
        KayakState.lastMagnitude = magnitude;
        var change = Math.abs(delta);
        var threshold = Math.max(0.35, KayakState.noiseFloor * 3.0);
        var now = System.getTimer();

        // Count a sufficiently strong upward motion change, with a refractory period
        // to avoid counting the same paddle stroke more than once.
        if (delta > threshold && (now - KayakState.lastStrokeTime) > 400) {
            KayakState.strokes += 1;
            KayakState.lastStrokeTime = now;
            KayakState.strokeTimes.add(now);
        } else if (change < threshold) {
            // Adapt to ordinary movement without letting a detected stroke inflate
            // the threshold and suppress subsequent strokes.
            KayakState.noiseFloor = (KayakState.noiseFloor * 0.97) + (change * 0.03);
        }

        // Keep only recent strokes; cadence is strokes in the last minute.
        while (KayakState.strokeTimes.size() > 0 &&
               (now - KayakState.strokeTimes[0]) > 60000) {
            KayakState.strokeTimes.remove(0);
        }
    }
}

class KayakState {
    static var running = false;
    static var hasStarted = false;
    static var sensorAvailable = true;
    static var strokes = 0;
    static var elapsedSeconds = 0;
    static var lastMagnitude = 0.0;
    static var hasMagnitude = false;
    static var noiseFloor = 0.0;
    static var lastStrokeTime = 0;
    static var strokeTimes = [];

    static function reset() {
        running = false;
        hasStarted = false;
        sensorAvailable = true;
        strokes = 0;
        elapsedSeconds = 0;
        strokeTimes = [];
        resetDetector();
    }

    static function resetDetector() {
        lastMagnitude = 0.0;
        hasMagnitude = false;
        noiseFloor = 0.0;
        lastStrokeTime = 0;
    }

    static function resetSession() {
        strokes = 0;
        elapsedSeconds = 0;
        strokeTimes = [];
        resetDetector();
    }

    static function cadence() {
        var now = System.getTimer();
        var count = 0;
        for (var i = 0; i < strokeTimes.size(); i += 1) {
            if ((now - strokeTimes[i]) <= 60000) {
                count += 1;
            }
        }
        return count;
    }
}
