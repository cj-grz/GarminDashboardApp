using Toybox.Graphics;
using Toybox.Math;
using Theme;

module Draw {
    
    // Draw a circular progress ring
    // cx, cy: center coordinates
    // radius: outer radius of the ring
    // thickness: how thick the ring is
    // progress: 0.0 to 1.0
    // color: ring color
    function drawRing(dc, cx, cy, radius, thickness, progress, color) {
        // Draw base ring (dark gray)
        dc.setColor(Theme.COLOR_RING_BASE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(thickness);
        dc.drawCircle(cx, cy, radius);
        
        // Draw progress arc
        if (progress > 0.0) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(thickness);
            
            // Calculate arc angles (start at top, go clockwise)
            var startAngle = 270; // Top of circle (12 o'clock position)
            var sweepAngle = (progress * 360).toNumber();
            
            // Draw the arc by approximating with line segments
            var segments = 32;
            var prevX = null;
            var prevY = null;
            
            for (var i = 0; i <= segments; i++) {
                var fraction = i.toFloat() / segments.toFloat();
                if (fraction > progress) {
                    fraction = progress;
                }
                
                var angle = startAngle + (fraction * 360);
                var rad = Math.toRadians(angle);
                
                var x = cx + radius * Math.cos(rad);
                var y = cy + radius * Math.sin(rad);
                
                if (prevX != null) {
                    dc.drawLine(prevX, prevY, x, y);
                }
                
                prevX = x;
                prevY = y;
                
                if (fraction >= progress) {
                    break;
                }
            }
        }
    }
    
    // Draw centered text
    function drawCenteredText(dc, x, y, font, text, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    // Draw a complete metric gauge (ring + label + value)
    function drawMetricGauge(dc, cx, cy, radius, thickness, metricIndex, metricData) {
        var color = Theme.getMetricColor(metricIndex);
        var progress = metricData != null ? metricData.progress : 0.0;
        var formatted = metricData != null ? metricData.formatted : "—";
        
        // Draw the ring
        drawRing(dc, cx, cy, radius, thickness, progress, color);
        
        // Draw the value in the center
        dc.setColor(Theme.COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_TINY, formatted, 
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    // Calculate position for a gauge in the circular layout
    // index: 0-7 for the 8 gauges
    // centerX, centerY: center of the watch face
    // ringRadius: distance from center to each gauge
    function getGaugePosition(index, centerX, centerY, ringRadius) {
        // Start at top (12 o'clock) and go clockwise
        var angle = -90 + (index * 45); // -90 starts at top, 45° between each gauge
        var rad = Math.toRadians(angle);
        
        var x = centerX + (ringRadius * Math.cos(rad));
        var y = centerY + (ringRadius * Math.sin(rad));
        
        return [x, y];
    }
    
    // Draw small icon/label above or near the gauge
    function drawMetricLabel(dc, cx, cy, metricIndex, radius) {
        var label = Theme.getMetricLabel(metricIndex);
        var color = Theme.getMetricColor(metricIndex);
        
        // Position label above the gauge
        var labelY = cy - radius - 10;
        
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, Graphics.FONT_XTINY, label,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
