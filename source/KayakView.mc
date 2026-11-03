using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;

class KayakView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var width = dc.getWidth();
        var y = 16;
        drawCentered(dc, "KAYAK", y, Graphics.FONT_MEDIUM);
        y += 38;
        drawCentered(dc, KayakState.running ? "EDZES FOLYAMATBAN" : "SELECT: INDÍT / LEÁLLÍT", y, Graphics.FONT_XTINY);
        y += 34;
        drawCentered(dc, KayakState.strokes.toString(), y, Graphics.FONT_NUMBER_HUGE);
        y += 68;
        drawCentered(dc, "CSAPAS", y, Graphics.FONT_XTINY);
        y += 24;
        drawCentered(dc, KayakState.cadence().toString() + " csapas/perc", y, Graphics.FONT_MEDIUM);
        y += 34;
        drawCentered(dc, formatTime(KayakState.elapsedSeconds), y, Graphics.FONT_SMALL);
        y += 24;
        if (!KayakState.sensorAvailable) {
            drawCentered(dc, "ERZEKELŐ NEM ELÉRHETO", y, Graphics.FONT_XTINY);
        }
    }

    function drawCentered(dc, text, y, font) {
        var width = dc.getWidth();
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
            KayakState.running = true;
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() {
        if (KayakState.running) {
            KayakState.running = false;
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }
}
