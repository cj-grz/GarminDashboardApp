using Toybox.Graphics;

module Theme {

    // Neon color palette
    const COLOR_CYAN   = 0x00FFFF;
    const COLOR_BLUE   = 0x0080FF;
    const COLOR_PURPLE = 0xA020F0;
    const COLOR_PINK   = 0xFF1493;
    const COLOR_RED    = 0xFF0040;
    const COLOR_ORANGE = 0xFF8000;
    const COLOR_YELLOW = 0xFFFF00;
    const COLOR_GREEN  = 0x00FF80;
    const COLOR_TEAL   = 0x00CED1;

    // Background and UI colors
    const COLOR_BACKGROUND = Graphics.COLOR_BLACK;
    const COLOR_TEXT       = Graphics.COLOR_WHITE;
    const COLOR_TEXT_DIM   = 0x808080;
    const COLOR_RING_BASE  = 0x2A2A2A;

    // Metric indices as constants (simpler than enum for module access)
    const STEPS        = 0;
    const CALORIES     = 1;
    const BATTERY      = 2;
    const VO2MAX       = 3;
    const BODY_BATTERY = 4;
    const STRESS       = 5;
    const HEART_RATE   = 6;
    const RECOVERY     = 7;

    function metricCount() {
        return 8;
    }

    function getMetricColor(metricIndex) {
        switch (metricIndex) {
            case STEPS:        return COLOR_ORANGE;
            case CALORIES:     return COLOR_BLUE;
            case BATTERY:      return COLOR_CYAN;
            case VO2MAX:       return COLOR_PURPLE;
            case BODY_BATTERY: return COLOR_GREEN;
            case STRESS:       return COLOR_YELLOW;
            case HEART_RATE:   return COLOR_RED;
            case RECOVERY:     return COLOR_PINK;
            default:           return COLOR_TEXT;
        }
    }

    function getMetricLabel(metricIndex) {
        switch (metricIndex) {
            case STEPS:        return "STEPS";
            case CALORIES:     return "CAL";
            case BATTERY:      return "BAT";
            case VO2MAX:       return "VO2";
            case BODY_BATTERY: return "BODY";
            case STRESS:       return "STRS";
            case HEART_RATE:   return "HR";
            case RECOVERY:     return "RCVR";
            default:           return "---";
        }
    }

    function getMetricIconId(metricIndex) {
        switch (metricIndex) {
            case STEPS:        return :ic_steps;
            case CALORIES:     return :ic_cal;
            case BATTERY:      return :ic_battery;
            case VO2MAX:       return :ic_vo2;
            case BODY_BATTERY: return :ic_body;
            case STRESS:       return :ic_stress;
            case HEART_RATE:   return :ic_hr;
            case RECOVERY:     return :ic_recovery;
            default:           return null;
        }
    }
}