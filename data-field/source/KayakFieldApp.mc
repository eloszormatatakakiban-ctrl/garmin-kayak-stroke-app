using Toybox.Application;
using Toybox.Lang;
using Toybox.Sensor;
using Toybox.System;
using Toybox.WatchUi;

class KayakFieldApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
        KayakFieldState.reset();
    }

    function getInitialView() {
        return [new KayakStrokeField()];
    }

    function onStart(state) as Void {
        KayakFieldState.reset();
        try {
            Sensor.registerSensorDataListener(method(:onSensorData), {
                :period => 100,
                :accelerometer => { :enabled => true }
            });
        } catch (e) {
            KayakFieldState.sensorAvailable = false;
        }
    }

    function onStop(state) as Void {
        try {
            Sensor.unregisterSensorDataListener();
        } catch (e) {
            // Listener may not have been registered in this device context.
        }
    }

    function onSensorData(data as Sensor.SensorData) as Void {
        if (data == null || data.accelerometerData == null) {
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
            KayakFieldState.addSample(xs[i] / 1000.0, ys[i] / 1000.0,
                zs[i] / 1000.0, System.getTimer());
        }
        WatchUi.requestUpdate();
    }
}

class KayakFieldState {
    static var strokes = 0;
    static var strokeTimes as Lang.Array<Lang.Number> = [];
    static var gravityX = 0.0;
    static var gravityY = 0.0;
    static var gravityZ = 0.0;
    static var hasGravity = false;
    static var armed = true;
    static var sensorAvailable = true;
    static var tiltDegrees = 0.0;
    static var latestSignal = 0.0;
    static var lastStrokeTime = 0;

    static function reset() as Void {
        strokes = 0;
        strokeTimes = [];
        gravityX = 0.0;
        gravityY = 0.0;
        gravityZ = 0.0;
        hasGravity = false;
        armed = true;
        sensorAvailable = true;
        tiltDegrees = 0.0;
        latestSignal = 0.0;
        lastStrokeTime = 0;
    }

    static function setting(name as Lang.String, fallback as Lang.Number) as Lang.Number {
        var value = Application.getApp().getProperty(name);
        if (value == null) {
            return fallback;
        }
        return value as Lang.Number;
    }

    static function addSample(x as Lang.Float, y as Lang.Float, z as Lang.Float,
                              now as Lang.Number) as Void {
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
        var magnitude = Math.sqrt((dx * dx) + (dy * dy) + (dz * dz));
        var signalMode = setting("DetectionSignal", 0).toNumber();
        if (signalMode == 1) {
            latestSignal = Math.abs(dx);
        } else if (signalMode == 2) {
            latestSignal = Math.abs(dy);
        } else if (signalMode == 3) {
            latestSignal = Math.abs(dz);
        } else if (signalMode == 4) {
            var gravityMagnitude = Math.sqrt((gravityX * gravityX) +
                (gravityY * gravityY) + (gravityZ * gravityZ));
            latestSignal = 0.0;
            if (gravityMagnitude > 0.1) {
                latestSignal = Math.abs(((dx * gravityX) + (dy * gravityY) +
                    (dz * gravityZ)) / gravityMagnitude);
            }
        } else {
            latestSignal = magnitude;
        }

        var threshold = setting("StrokeThreshold", 0.18);
        var interval = setting("MinimumInterval", 600).toNumber();
        if (latestSignal < (threshold * 0.45)) {
            armed = true;
        } else if (armed && latestSignal >= threshold &&
                   (now - lastStrokeTime) >= interval) {
            strokes += 1;
            lastStrokeTime = now;
            strokeTimes.add(now);
            armed = false;
        }

        // Follow slow orientation changes while excluding most fast stroke motion.
        var alpha = magnitude < 1.5 ? 0.02 : 0.002;
        gravityX += (x - gravityX) * alpha;
        gravityY += (y - gravityY) * alpha;
        gravityZ += (z - gravityZ) * alpha;

        var horizontal = Math.sqrt((gravityX * gravityX) + (gravityY * gravityY));
        tiltDegrees = Math.atan2(horizontal, Math.abs(gravityZ)) * 180.0 / 3.14159265;
        prune(now);
    }

    static function prune(now as Lang.Number) as Void {
        while (strokeTimes.size() > 0 && (now - strokeTimes[0]) > 60000) {
            strokeTimes.remove(strokeTimes[0]);
        }
    }

    static function cadence() as Lang.Number {
        prune(System.getTimer());
        return strokeTimes.size();
    }
}

class KayakStrokeField extends WatchUi.DataField {
    function initialize() {
        DataField.initialize();
    }

    function compute(info) {
        // Custom sensor values are rendered in onUpdate().
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var width = dc.getWidth();
        var height = dc.getHeight();
        drawCentered(dc, "KAYAK", width, 16, Graphics.FONT_SMALL);
        drawCentered(dc, KayakFieldState.sensorAvailable ? "STROKES" : "SENSOR N/A",
            width, 48, Graphics.FONT_XTINY);
        drawCentered(dc, KayakFieldState.strokes.toString(), width,
            height / 2 - 70, Graphics.FONT_LARGE);
        drawCentered(dc, KayakFieldState.cadence().toString() + " / MIN",
            width, height / 2 - 15, Graphics.FONT_MEDIUM);
        drawCentered(dc, "TILT  " + KayakFieldState.tiltDegrees.toNumber().toString() + " deg",
            width, height / 2 + 28, Graphics.FONT_SMALL);
        drawCentered(dc, "POWER  -- W", width, height / 2 + 58, Graphics.FONT_XTINY);
        drawCentered(dc, "FORCE  --", width, height / 2 + 78, Graphics.FONT_XTINY);
        drawCentered(dc, "TUNE IN CONNECT IQ SETTINGS", width,
            height - 24, Graphics.FONT_XTINY);
    }

    function drawCentered(dc, text, width, y, font) {
        dc.drawText(width / 2, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
