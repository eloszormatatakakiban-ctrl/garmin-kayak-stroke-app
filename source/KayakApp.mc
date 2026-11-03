using Toybox.Application;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.WatchUi;

class KayakApp extends Application.AppBase {
    var _view;
    var _timer;

    function initialize() {
        AppBase.initialize();
        KayakState.reset();
    }

    function getInitialView() {
        _view = new KayakView();
        return [_view, new KayakDelegate()];
    }

    function onStart(state) {
        KayakState.running = false;
        KayakState.lastMagnitude = 0.0;
        KayakState.noiseFloor = 0.0;
        KayakState.lastStrokeTime = 0;
        try {
            Sensor.registerSensorDataListener(method(:onSensorData), { :period => 1, :accelerometer => true });
        } catch (e) {
            KayakState.sensorAvailable = false;
        }
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 1000, true);
    }

    function onStop(state) {
        if (_timer != null) {
            _timer.stop();
        }
        try {
            Sensor.unregisterSensorDataListener();
        } catch (e) {
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
        var a = data.accel;
        if (a.size() < 3) {
            return;
        }

        // Acceleration magnitude removes dependence on how the watch is oriented on the kayak.
        var magnitude = Math.sqrt((a[0] * a[0]) + (a[1] * a[1]) + (a[2] * a[2]));
        var delta = magnitude - KayakState.lastMagnitude;
        KayakState.lastMagnitude = magnitude;
        var absDelta = Math.abs(delta);

        // Slowly learn the normal movement level, then count a sufficiently strong local change.
        KayakState.noiseFloor = (KayakState.noiseFloor * 0.97) + (absDelta * 0.03);
        var threshold = Math.max(0.35, KayakState.noiseFloor * 3.0);
        var now = System.getTimer();
        if (delta > threshold && (now - KayakState.lastStrokeTime) > 350) {
            KayakState.strokes += 1;
            KayakState.lastStrokeTime = now;
            KayakState.strokeTimes.add(now);
            while (KayakState.strokeTimes.size() > 30) {
                KayakState.strokeTimes.remove(0);
            }
        }
    }
}

class KayakState {
    static var running = false;
    static var sensorAvailable = true;
    static var strokes = 0;
    static var elapsedSeconds = 0;
    static var lastMagnitude = 0.0;
    static var noiseFloor = 0.0;
    static var lastStrokeTime = 0;
    static var strokeTimes = [];

    static function reset() {
        running = false;
        sensorAvailable = true;
        strokes = 0;
        elapsedSeconds = 0;
        lastMagnitude = 0.0;
        noiseFloor = 0.0;
        lastStrokeTime = 0;
        strokeTimes = [];
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
