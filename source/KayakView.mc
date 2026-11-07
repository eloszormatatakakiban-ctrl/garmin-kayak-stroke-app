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
        // Garmin workout metrics are supplied by the activity. Cache them here;
        // compute() and onUpdate() are not guaranteed to run in sequence.
        if (info != null) {
            _speedText = info.currentSpeed != null ?
                (info.currentSpeed * 3.6).format("%.1f") : "--";
            _heartRateText = info.currentHeartRate != null ?
                info.currentHeartRate.toNumber().toString() : "--";
            _distanceText = info.currentDistance != null ?
                (info.currentDistance / 1000.0).format("%.2f") : "--";
            _timeText = info.timerTime != null ? formatTime(info.timerTime) : "--:--";
            _powerText = info.currentPower != null ?
                info.currentPower.toNumber().toString() : "--";
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
        var compact = width < 300 || height < 300;

        // High-contrast, uncluttered hierarchy: stroke count first, then the
        // standard workout values, followed by clearly marked estimates.
        dc.drawText(centerX, 2, Graphics.FONT_XTINY, "KAYAK  •  LIVE",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, height * 0.09, Graphics.FONT_LARGE,
            KayakState.strokes.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, height * 0.29, Graphics.FONT_XTINY,
            "STROKES", Graphics.TEXT_JUSTIFY_CENTER);

        var leftX = width * 0.27;
        var rightX = width * 0.73;
        var y1 = height * 0.40;
        var y2 = height * 0.54;
        var y3 = height * 0.68;
        drawMetric(dc, leftX, y1, "SPEED", _speedText + " km/h");
        drawMetric(dc, rightX, y1, "HEART", _heartRateText + " bpm");
        drawMetric(dc, leftX, y2, "DISTANCE", _distanceText + " km");
        drawMetric(dc, rightX, y2, "TIME", _timeText);

        var forceText = KayakState.sensorAvailable ?
            KayakState.forceProxy.format("%.1f") + " g*" : "--";
        var stabilityText = KayakState.sensorAvailable ?
            KayakState.stability.toNumber().toString() + "%*" : "--";
        var staminaText = KayakState.staminaEstimate.toNumber().toString() + "%*";

        if (!compact) {
            drawMetric(dc, leftX, y3, "POWER", _powerText + " W");
            drawMetric(dc, rightX, y3, "FORCE", forceText);
            dc.drawText(centerX, height * 0.82, Graphics.FONT_XTINY,
                "STAMINA " + staminaText + "   STABILITY " + stabilityText,
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(centerX, height * 0.93, Graphics.FONT_XTINY,
                "*ESTIMATES  |  POWER NEEDS A METER",
                Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(centerX, y3, Graphics.FONT_XTINY,
                "POWER " + _powerText + " W  |  FORCE " + forceText,
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(centerX, height * 0.82, Graphics.FONT_XTINY,
                "STAMINA " + staminaText + "  STAB " + stabilityText,
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(centerX, height * 0.93, Graphics.FONT_XTINY,
                "*ESTIMATES", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawMetric(dc, x, y, title, value) {
        dc.drawText(x, y, Graphics.FONT_XTINY, title, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, y + 13, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function formatTime(seconds) {
        var totalSeconds = seconds.toNumber();
        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var remainder = totalSeconds % 60;
        var minuteText = minutes < 10 ? "0" + minutes.toString() : minutes.toString();
        var secondText = remainder < 10 ? "0" + remainder.toString() : remainder.toString();
        if (hours > 0) {
            var hourText = hours < 10 ? "0" + hours.toString() : hours.toString();
            return hourText + ":" + minuteText + ":" + secondText;
        }
        return minutes.toString() + ":" + secondText;
    }
}
