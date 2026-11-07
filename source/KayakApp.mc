using Toybox.Application;
using Toybox.Sensor;
using Toybox.System;
using Toybox.WatchUi;

class KayakApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
        KayakState.reset();
    }

    function getInitialView() {
        return [ new KayakDataField() ];
    }

    function onStart(state) as Void {
        KayakState.reset();
        try {
            Sensor.registerSensorDataListener(method(:onSensorData), {
                :period => 100,
                :accelerometer => { :enabled => true }
            });
            KayakState.sensorAvailable = true;
        } catch (e) {
            KayakState.sensorAvailable = false;
        }
    }

    function onStop(state) as Void {
        try {
            Sensor.unregisterSensorDataListener();
        } catch (e) {
            // Sensor listener may not have been registered on this device.
        }
    }

    function onSensorData(data) as Void {
        if (!KayakState.running || data == null || data.accelerometerData == null) {
            return;
        }

        var accel = data.accelerometerData;
        var xs = accel.x;
        var ys = accel.y;
        var zs = accel.z;
        if (xs == null || ys == null || zs == null) {
            return;
        }

        var count = xs.size();
        if (ys.size() < count) { count = ys.size(); }
        if (zs.size() < count) { count = zs.size(); }

        for (var i = 0; i < count; i += 1) {
            // Connect IQ accelerometer samples are in milli-g.
            KayakState.processSample(xs[i] / 1000.0, ys[i] / 1000.0, zs[i] / 1000.0,
                System.getTimer());
        }
    }
}

class KayakState {
    static var running = false;
    static var sensorAvailable = false;
    static var strokes = 0;
    static var strokeArmed = true;
    static var hasGravity = false;
    static var gravityX = 0.0;
    static var gravityY = 0.0;
    static var gravityZ = 0.0;
    static var lastStrokeTime = 0;
    static var forceProxy = 0.0;
    static var stability = 100.0;
    static var staminaEstimate = 100.0;

    static function reset() as Void {
        running = false;
        strokes = 0;
        strokeArmed = true;
        hasGravity = false;
        gravityX = 0.0;
        gravityY = 0.0;
        gravityZ = 0.0;
        lastStrokeTime = 0;
        forceProxy = 0.0;
        stability = 100.0;
        staminaEstimate = 100.0;
    }

    static function processSample(x, y, z, now) as Void {
        if (!hasGravity) {
            gravityX = x;
            gravityY = y;
            gravityZ = z;
            hasGravity = true;
            return;
        }

        var dx = x - gravityX;
        var dy = y - gravityY;
        var dz = z - gravityZ;
        var motion = Math.sqrt((dx * dx) + (dy * dy) + (dz * dz));
        forceProxy = (forceProxy * 0.85) + (motion * 0.15);
        stability = Math.max(0.0, Math.min(100.0, 100.0 - (motion * 25.0)));

        // Slowly follow gravity so short paddle impulses remain detectable.
        var alpha = motion < 0.35 ? 0.02 : 0.002;
        gravityX += (x - gravityX) * alpha;
        gravityY += (y - gravityY) * alpha;
        gravityZ += (z - gravityZ) * alpha;

        var threshold = 0.08;
        if (motion < (threshold * 0.55)) {
            strokeArmed = true;
        } else if (strokeArmed && motion >= threshold && (now - lastStrokeTime) > 350) {
            strokes += 1;
            lastStrokeTime = now;
            strokeArmed = false;
            staminaEstimate = Math.max(0.0, staminaEstimate - 0.1);
        }
    }
}
