using Toybox.Application;
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
    }

    function compute(info) {
        // Cache Garmin workout values because compute() and onUpdate() can run asynchronously.
        if (info != null) {
            _speedText = info.currentSpeed != null ?
                (info.currentSpeed * 3.6).format("%.1f") : "--";
            _heartRateText = info.currentHeartRate != null ?
                info.currentHeartRate.toNumber().toString() : "--";
            // This SDK's Activity.Info does not expose a supported distance property.
            _distanceText = "--";
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
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var background = Graphics.COLOR_BLACK;
        var foreground = Graphics.COLOR_WHITE;
        var accent = getAccentColor();
        var compact = getSetting("CompactLayout", false);

        dc.setColor(foreground, background);
        dc.clear();
        dc.drawText(centerX, 2, Graphics.FONT_XTINY, "KAYAK  |  LIVE",
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(accent, background);
        dc.drawText(centerX, height * 0.09,
            compact ? Graphics.FONT_MEDIUM : Graphics.FONT_LARGE,
            KayakState.strokes.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(foreground, background);
        dc.drawText(centerX, height * 0.27, Graphics.FONT_XTINY, "STROKES",
            Graphics.TEXT_JUSTIFY_CENTER);

        var leftX = width * 0.27;
        var rightX = width * 0.73;
        var row1 = height * 0.38;
        var row2 = height * 0.52;
        var row3 = height * 0.66;
        var row4 = height * 0.80;
        var showSpeed = getSetting("ShowSpeed", true);
        var showHeart = getSetting("ShowHeartRate", true);
        var showDistance = getSetting("ShowDistance", true);
        var showTimer = getSetting("ShowTimer", true);
        var showPower = getSetting("ShowPower", true);
        var showEstimates = getSetting("ShowEstimates", true);

        if (showSpeed) {
            drawMetric(dc, leftX, row1, "SPEED", _speedText + " km/h", accent, foreground, background);
        }
        if (showHeart) {
            drawMetric(dc, rightX, row1, "HEART", _heartRateText + " bpm", accent, foreground, background);
        }
        if (showDistance) {
            drawMetric(dc, leftX, row2, "DISTANCE", _distanceText, accent, foreground, background);
        }
        if (showTimer) {
            drawMetric(dc, rightX, row2, "TIME", _timeText, accent, foreground, background);
        }
        if (showPower) {
            drawMetric(dc, leftX, row3, "POWER", _powerText + " W", accent, foreground, background);
        }
        if (showEstimates) {
            var forceText = KayakState.sensorAvailable ?
                KayakState.forceProxy.format("%.1f") + " g*" : "--";
            var stabilityText = KayakState.sensorAvailable ?
                KayakState.stability.toNumber().toString() + "%*" : "--";
            var staminaText = KayakState.staminaEstimate.toNumber().toString() + "%*";
            drawMetric(dc, rightX, row3, "MOTION*", forceText, accent, foreground, background);
            dc.setColor(foreground, background);
            dc.drawText(centerX, row4, Graphics.FONT_XTINY,
                "STAMINA " + staminaText + "   STABILITY " + stabilityText,
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(foreground, background);
        dc.drawText(centerX, height * 0.93, Graphics.FONT_XTINY,
            showPower ? "*MOTION ESTIMATE  |  W NEEDS POWER METER" : "*MOTION VALUES ARE ESTIMATES",
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawMetric(dc, x, y, title, value, accent, foreground, background) {
        dc.setColor(accent, background);
        dc.drawText(x, y, Graphics.FONT_XTINY, title, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(foreground, background);
        dc.drawText(x, y + 13, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function getSetting(name, fallback) {
        var value = Application.getApp().getProperty(name);
        return value == null ? fallback : value;
    }

    function getAccentColor() {
        var theme = getSetting("Theme", 0);
        if (theme == 1) {
            return Graphics.COLOR_BLUE;
        } else if (theme == 2) {
            return Graphics.COLOR_YELLOW;
        }
        return Graphics.COLOR_GREEN;
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
