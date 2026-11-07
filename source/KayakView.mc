using Toybox.Graphics;
using Toybox.WatchUi;

class KayakView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        drawCentered(dc, "KAYAK ANALYTICS", width, 16, Graphics.FONT_SMALL);

        var status = KayakState.running ? "RECORDING" :
            (KayakState.sessionFinished ? "SESSION STOPPED" :
             (KayakState.hasStarted ? "PAUSED" : "SELECT: START"));
        drawCentered(dc, status, width, 44, Graphics.FONT_XTINY);

        drawCentered(dc, KayakState.strokes.toString(), width,
            height / 2 - 112, Graphics.FONT_NUMBER_XLARGE);
        drawCentered(dc, "STROKES", width,
            height / 2 - 42, Graphics.FONT_XTINY);
        drawCentered(dc, KayakState.cadence().toString() + " / MIN",
            width, height / 2 - 7, Graphics.FONT_MEDIUM);
        drawCentered(dc, "AVG " + KayakState.averageCadence().toString() + " / MIN",
            width, height / 2 + 28, Graphics.FONT_XTINY);
        drawCentered(dc, "TIME  " + formatTime(KayakState.elapsedSeconds),
            width, height / 2 + 54, Graphics.FONT_SMALL);

        if (KayakState.sensorAvailable) {
            drawCentered(dc, "HULL MOTION  " +
                formatDecimal(KayakState.verticalRange()), width,
                height / 2 + 86, Graphics.FONT_XTINY);
            drawCentered(dc, "ACCELERATION  " +
                formatDecimal(KayakState.verticalAcceleration), width,
                height / 2 + 106, Graphics.FONT_XTINY);
        } else {
            drawCentered(dc, "ACCELEROMETER UNAVAILABLE", width,
                height / 2 + 90, Graphics.FONT_XTINY);
        }

        drawCentered(dc, "POWER REQUIRES A POWER METER", width,
            height - 48, Graphics.FONT_XTINY);

        var controls = KayakState.running ? "SELECT: PAUSE  BACK: STOP" :
            "MENU: RESET";
        drawCentered(dc, controls, width, height - 28, Graphics.FONT_XTINY);
    }

    function drawCentered(dc, text, width, y, font) {
        dc.drawText(width / 2, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function formatTime(seconds) {
        var minutes = seconds / 60;
        var remainder = seconds % 60;
        var secText = remainder < 10 ? "0" + remainder.toString() : remainder.toString();
        return minutes.toString() + ":" + secText;
    }

    function formatDecimal(value) {
        return (value * 100).toNumber().toString() + " x 0.01";
    }
}

class KayakDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        if (KayakState.running) {
            KayakState.running = false;
        } else {
            if (!KayakState.hasStarted || KayakState.sessionFinished) {
                KayakState.resetSession();
                KayakState.hasStarted = true;
                KayakState.sessionFinished = false;
            }
            KayakState.running = true;
            KayakState.resetDetector();
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() {
        if (KayakState.running || KayakState.hasStarted) {
            KayakState.running = false;
            KayakState.hasStarted = false;
            KayakState.sessionFinished = true;
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    function onMenu() {
        if (!KayakState.running) {
            KayakState.resetSession();
            KayakState.hasStarted = false;
            KayakState.sessionFinished = false;
            WatchUi.requestUpdate();
        }
        return true;
    }
}
