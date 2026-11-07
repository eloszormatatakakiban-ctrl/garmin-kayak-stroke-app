using Toybox.Graphics;
using Toybox.WatchUi;

class KayakDataField extends WatchUi.DataField {
    function initialize() {
        DataField.initialize();
        label = "Kayak Metrics";
    }

    function compute(info) {
        // The native data-field value is stroke count; the custom display below
        // also renders the other kayak metrics.
        return KayakState.strokes;
    }

    function onTimerStart() {
        KayakState.reset();
        KayakState.running = true;
    }

    function onTimerResume() {
        KayakState.running = true;
    }

    function onTimerPause() {
        KayakState.running = false;
    }

    function onTimerStop() {
        KayakState.running = false;
    }

    function onTimerReset() {
        KayakState.reset();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.drawText(width / 2, 4, Graphics.FONT_SMALL, "KAYAK", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, height * 0.18, Graphics.FONT_LARGE,
            KayakState.strokes.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, height * 0.38, Graphics.FONT_XTINY,
            "STROKES", Graphics.TEXT_JUSTIFY_CENTER);

        var watts = "--";
        var forceText = "--";
        var stabilityText = "--";
        if (KayakState.sensorAvailable) {
            forceText = KayakState.forceProxy.format("%.2f") + " g*";
            stabilityText = KayakState.stability.toNumber().toString() + "%*";
        }
        var staminaText = KayakState.staminaEstimate.toNumber().toString() + "%*";
        var rowY = height * 0.52;
        dc.drawText(width / 2, rowY, Graphics.FONT_SMALL,
            "W " + watts + "   F " + forceText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, rowY + 28, Graphics.FONT_SMALL,
            "STAMINA " + staminaText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, rowY + 54, Graphics.FONT_SMALL,
            "STABILITY " + stabilityText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(width / 2, height - 20, Graphics.FONT_XTINY,
            "*ESTIMATE   WATTS: POWER METER NEEDED", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
