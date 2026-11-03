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
            // Sensor registration may not be available on every device/profile.
        }
    }

    function onTick() {
        if (KayakState.running) {
            KayakState.elapsedSeconds += 1;
        }
        KayakState.pruneStrokeTimes(System.getTimer());
        WatchUi.requestUpdate();
    }

    function onSensorData(data) {
        if (!KayakState.running || data == null || data.accel == null) {
            return;
        }

        var a = data.accel;
        if (a.size() < 3) {
            return;
        }

        var x = a[0];
        var y = a[1];
        var z = a[2];

        // The watch is fixed to the boat. Learn the gravity direction in that
        // mounting orientation, then measure acceleration relative to it.
        if (!KayakState.hasGravity) {
            KayakState.gravityX = x;
            KayakState.gravityY = y;
            KayakState.gravityZ = z;
            KayakState.hasGravity = true;
            return;
        }

        var dx = x - KayakState.gravityX;
        var dy = y - KayakState.gravityY;
        var dz = z - KayakState.gravityZ;
        var motion = Math.sqrt((dx * dx) + (dy * dy) + (dz * dz));

        var gravityMagnitude = Math.sqrt(
            (KayakState.gravityX * KayakState.gravityX) +
            (KayakState.gravityY * KayakState.gravityY) +
            (KayakState.gravityZ * KayakState.gravityZ)
        );
        var verticalMotion = 0.0;
        if (gravityMagnitude > 0.1) {
            verticalMotion = Math.abs(
                ((dx * KayakState.gravityX) +
                 (dy * KayakState.gravityY) +
                 (dz * KayakState.gravityZ)) / gravityMagnitude
            );
        }

        KayakState.motionMagnitude = motion;
        KayakState.verticalAcceleration = verticalMotion;
        KayakState.addVerticalSample(verticalMotion);

        // Adapt the gravity estimate slowly. This avoids treating every paddle
        // impulse as a change in the watch's mounting orientation.
        var gravityAlpha = motion < 2.0 ? 0.015 : 0.002;
        KayakState.gravityX += (x - KayakState.gravityX) * gravityAlpha;
        KayakState.gravityY += (y - KayakState.gravityY) * gravityAlpha;
        KayakState.gravityZ += (z - KayakState.gravityZ) * gravityAlpha;

        var now = System.getTimer();
        var threshold = Math.max(1.0, KayakState.noiseFloor * 3.0);

        // Hysteresis arms the detector only after motion falls back below the
        // low threshold. The refractory interval avoids duplicate counts.
        if (motion < (threshold * 0.55)) {
            KayakState.strokeArmed = true;
        } else if (KayakState.strokeArmed && motion >= threshold &&
                   (now - KayakState.lastStrokeTime) > 700) {
            KayakState.strokes += 1;
            KayakState.lastStrokeTime = now;
            KayakState.strokeTimes.add(now);
            KayakState.strokeArmed = false;
        }

        // Learn background movement only from low-amplitude samples so a stroke
        // does not immediately raise its own detection threshold.
        if (motion < threshold) {
            KayakState.noiseFloor = (KayakState.noiseFloor * 0.98) + (motion * 0.02);
        }
        KayakState.pruneStrokeTimes(now);
    }
}

class KayakState {
    static var running = false;
    static var hasStarted = false;
    static var sessionFinished = false;
    static var sensorAvailable = true;
    static var strokes = 0;
    static var elapsedSeconds = 0;
    static var strokeTimes = [];
    static var verticalSamples = [];
    static var gravityX = 0.0;
    static var gravityY = 0.0;
    static var gravityZ = 0.0;
    static var hasGravity = false;
    static var noiseFloor = 0.0;
    static var motionMagnitude = 0.0;
    static var verticalAcceleration = 0.0;
    static var lastStrokeTime = 0;
    static var strokeArmed = true;

    static function reset() {
        running = false;
        hasStarted = false;
        sessionFinished = false;
        sensorAvailable = true;
        resetSession();
    }

    static function resetDetector() {
        gravityX = 0.0;
        gravityY = 0.0;
        gravityZ = 0.0;
        hasGravity = false;
        noiseFloor = 0.0;
        motionMagnitude = 0.0;
        verticalAcceleration = 0.0;
        lastStrokeTime = 0;
        strokeArmed = true;
    }

    static function resetSession() {
        strokes = 0;
        elapsedSeconds = 0;
        strokeTimes = [];
        verticalSamples = [];
        resetDetector();
    }

    static function addVerticalSample(value) {
        verticalSamples.add(value);
        // Bounded rolling window for recent hull-motion diagnostics.
        while (verticalSamples.size() > 30) {
            verticalSamples.remove(0);
        }
    }

    static function verticalRange() {
        if (verticalSamples.size() == 0) {
            return 0.0;
        }
        var low = verticalSamples[0];
        var high = verticalSamples[0];
        for (var i = 1; i < verticalSamples.size(); i += 1) {
            if (verticalSamples[i] < low) {
                low = verticalSamples[i];
            }
            if (verticalSamples[i] > high) {
                high = verticalSamples[i];
            }
        }
        return high - low;
    }

    static function pruneStrokeTimes(now) {
        while (strokeTimes.size() > 0 && (now - strokeTimes[0]) > 60000) {
            strokeTimes.remove(0);
        }
    }

    static function cadence() {
        return strokeTimes.size();
    }

    static function averageCadence() {
        if (elapsedSeconds <= 0) {
            return 0;
        }
        return (strokes * 60) / elapsedSeconds;
    }
}
