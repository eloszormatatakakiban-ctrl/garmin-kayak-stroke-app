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
        drawCentered(dc, "KAYAK STROKE", width, 18, Graphics.FONT_SMALL);

        var status = KayakState.running ? "MÉRÉS FOLYAMATBAN" :
            (KayakState.hasStarted ? "SZÜNETEL" : "SELECT: INDÍTÁS");
        drawCentered(dc, status, width, 54, Graphics.FONT_XTINY);

        drawCentered(dc, KayakState.strokes.toString(), width,
            height / 2 - 100, Graphics.FONT_NUMBER_H田GE);
        drawCentered(dc, "CSAPÁS", width, height / 2 - 32, Graphics.FONT_XTINY);

        drawCentered(dc, KayakState.cadence().toString() + " csapás/perc",
            width, height / 2 + 12, Graphics.FONT_MEDIUM);
        drawCentered(dc, formatTime(KayakState.elapsedSeconds),
            width, height / 2 + 52, Graphics.FONT_SMALL);

        if (!KayakState.sensorAvailable) {
            drawCentered(dc, "NINCS ÉRZÉKELŐADAT", width,
                height - 46, Graphics.FONT_XTINY);
        } else if (!KayakState.running) {
            drawCentered(dc, "MENU: NULLÁZÁS", width,
                height - 46, Graphics.FONT_XTINY);
        } else {
            drawCentered(dc, "SELECT: SZÜNET  |  BACK: LEÁLLÍT", width,
                height - 46, Graphics.FONT_XTINY);
        }
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
}

class KayakDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        if (KayakState.running) {
            KayakState.running = false;
        } else {
            if (!KayakState.hasStarted) {
                KayakState.resetSession();
                KayakState.hasStarted = true;
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
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    function onMenu() {
        if (!KayakState.running) {
            KayakState.resetSession();
            KayakState.hasStarted = false;
            WatchUi.requestUpdate();
        }
        return true;
    }
}
