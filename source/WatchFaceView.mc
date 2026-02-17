using Theme;
using Draw;
using Metrics;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DashboardWatchFaceView extends WatchUi.WatchFace {

    // Cached metrics array
    var metrics;

    // Track last minute metrics were updated
    var lastMetricUpdateMin = -1;

    function initialize() {
        WatchFace.initialize();

        // Initial fetch
        metrics = Metrics.getAllMetrics();
    }

    function onUpdate(dc) {

        // Get current time
        var now = System.getClockTime();

        // Only refresh metrics once per minute
        if (lastMetricUpdateMin != now.min) {

            metrics = Metrics.getAllMetrics();

            lastMetricUpdateMin = now.min;
        }

        // Draw everything
        drawUI(dc, now);
    }

    function drawUI(dc, now) {

        var width = dc.getWidth();
        var height = dc.getHeight();

        var centerX = width / 2;
        var centerY = height / 2;

        // Gauge sizing
        var gaugeRadius    = width * 0.085;
        var gaugeThickness = width * 0.018;

        // For round watches (including fēnix 7X 51mm), compute ring radius from bounds
        // so gauges sit perfectly inside the bezel regardless of resolution.
        var edgePadding = width * 0.055;
        var minDimension = (width < height) ? width : height;
        var ringRadius = (minDimension / 2) - gaugeRadius - edgePadding;

        dc.setColor(Theme.COLOR_BACKGROUND, Theme.COLOR_BACKGROUND);
        dc.clear();

        // Draw gauges
        for (var i = 0; i < Theme.metricCount(); i++) {

            var pos = Draw.getGaugePosition(i, centerX, centerY, ringRadius);

            Draw.drawMetricGauge(
                dc,
                pos[0],
                pos[1],
                gaugeRadius,
                gaugeThickness,
                i,
                metrics[i]
            );
        }

        // Draw center time
        drawCenterTime(dc, centerX, centerY, now);
    }

    function drawCenterTime(dc, centerX, centerY, now) {

        var timeStr =
            now.hour.format("%02d") + ":" +
            now.min.format("%02d");

        dc.setColor(Theme.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            centerY - 10,
            Graphics.FONT_NUMBER_HOT,
            timeStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Get date info using Gregorian.info()
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        
        var dowNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dow = dowNames[today.day_of_week - 1];
        
        var day = today.day.format("%02d");
        var mon = today.month.format("%02d");

        var dateStr = dow + " " + day + " " + mon;

        dc.setColor(Theme.COLOR_TEXT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            centerY + 20,
            Graphics.FONT_SMALL,
            dateStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}