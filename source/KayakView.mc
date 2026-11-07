using Toybox.Graphics;
using Toybox.WatchUi;

class KayakDataField extends WatchUi.DataField {
    var _speedText = "--";
    var _heartRateText = "--";
    var _distanceText = "--";
    var _timeText = "--:--";
    var _powerText = "--";

    function initialize() {
        DataField.initialize();
        label = "Kayak Metrics";
    }

    function compute(info) {
        // Cache built-in workout values. compute() and onUpdate() may run
        // asynchronously, so onUpdate() only renders the latest cached values.
        if (info != null) {
            if (info.currentSpeed != null) {
                _speedText = (info.currentSpeed * 3.6).format("%.1f");
            } else {
                _speedText = "--";
            }

            if (info.currentHeartRate != null) {
                _heartRateText = info.currentHeartRate.toNumber().toString();
            } else {
                _heartRateText = "--";
            }

            if (info.currentDistance != null) {
                _distanceText = (info.currentDistance / 1000.0).format("%.2f");
            } else {
                _distanceText = "--";
            }

            if (info.timerTime != null) {
                _timeText = formatTime(info.timerTime);
            } else {
                _timeText = "--:--";
            }

            if (info.currentPower != null) {
                _powerText = info.currentPower.toNumber().toString();
            } else {
                _powerText = "--";
            }
        }
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
        var centerX = width / 2;

        dc.drawText(centerX, height * 0.02, Graphics.FONT_XTINY,
            "KAYAK  |  STROKES", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, height * 0.10, Graphics.FONT_LARGE,
            KayakState.strokes.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        var forceText = "--";
        var stabilityText = "--";
        var staminaText = KayakState.staminaEstimate.toNumber().toString() + "%*";
        if (KayakState.sensorAvailable) {
            forceText = KayakState.forceProxy.format("%.2f") + " g*";
            stabilityText = KayakState.stability.toNumber().toString() + "%*";
        }

        var row1 = height * 0.37;
        var row2 = height * 0.50;
        var row3 = height * 0.63;
        var row4 = height * 0.76;
        dc.drawText(centerX, row1, Graphics.FONT_SMALL,
            "SPD " + _speedText + " km/h   HR " + _heartRateText,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, row2, Graphics.FONT_SMALL,
            "DIST " + _distanceText + " km   TIME " + _timeText,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, row3, Graphics.FONT_SMALL,
            "W " + _powerText + "   FORCE " + forceText,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, row4, Graphics.FONT_SMALL,
            "STAMINA " + staminaText + "  STAB " + stabilityText,
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(centerX, height * 0.91, Graphics.FONT_XTINY,
            "*ESTIMATES; WATTS FROM POWER METER", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function formatTime(seconds) {
        var totalSeconds = seconds.toNumber();
        var minutes = totalSeconds / 60;
        var remainder = totalSeconds % 60;
        var secText = remainder < 10 ? "0" + remainder.toString() : remainder.toString();
        return minutes.toString() + ":" + secText;
    }
}
