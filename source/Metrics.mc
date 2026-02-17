using Toybox.System;
using Toybox.ActivityMonitor;
using Toybox.SensorHistory;
using Toybox.UserProfile;
using Toybox.Lang;

module Metrics {

    class MetricData {
        var value;
        var progress;   // 0.0 to 1.0
        var formatted;

        function initialize(v, p, f) {
            value = v;
            progress = p;
            formatted = f;
        }
    }

    // Main function to retrieve all metrics
    function getAllMetrics() {

        // Monkey C: use Array(size), not new [size]
        var metrics = new [8];

        metrics[0] = getSteps();
        metrics[1] = getCalories();
        metrics[2] = getBattery();
        metrics[3] = getVO2Max();
        metrics[4] = getBodyBattery();
        metrics[5] = getStress();
        metrics[6] = getHeartRate();
        metrics[7] = getRecovery();

        return metrics;
    }

    function getSteps() {
        var info = ActivityMonitor.getInfo();

        if (info != null && (info has :steps) && info.steps != null) {
            var steps = info.steps;

            // Step goal key varies; default is fine
            var goal = 10000;
            if ((info has :stepGoal) && info.stepGoal != null) {
                goal = info.stepGoal;
            }

            var progress = steps.toFloat() / goal.toFloat();
            if (progress > 1.0) { progress = 1.0; }

            return new MetricData(steps, progress, formatNumber(steps));
        }

        return new MetricData(0, 0.0, "—");
    }

    function getCalories() {
        var info = ActivityMonitor.getInfo();

        // Many devices expose :calories (active) or :activeCalories. We'll prefer :calories then fallback.
        var calories = null;

        if (info != null) {
            if ((info has :calories) && info.calories != null) {
                calories = info.calories;
            } else if ((info has :activeCalories) && info.activeCalories != null) {
                calories = info.activeCalories;
            }
        }

        if (calories != null) {
            var goal = 2000;
            if ((info has :calorieGoal) && info.calorieGoal != null) {
                goal = info.calorieGoal;
            }

            var progress = calories.toFloat() / goal.toFloat();
            if (progress > 1.0) { progress = 1.0; }

            return new MetricData(calories, progress, calories.format("%d"));
        }

        return new MetricData(0, 0.0, "—");
    }

    function getBattery() {
        var stats = System.getSystemStats();

        if (stats != null && (stats has :battery) && stats.battery != null) {
            var battery = stats.battery; // integer percent
            var progress = battery.toFloat() / 100.0;

            return new MetricData(battery, progress, battery.format("%d") + "%");
        }

        return new MetricData(0, 0.0, "—");
    }

    function getVO2Max() {
        var profile = UserProfile.getProfile();

        if (profile != null && (profile has :vo2maxRunning) && profile.vo2maxRunning != null) {
            var vo2 = profile.vo2maxRunning;

            // Map VO2 (20..70) => 0..1
            var progress = (vo2.toFloat() - 20.0) / 50.0;
            if (progress < 0.0) { progress = 0.0; }
            if (progress > 1.0) { progress = 1.0; }

            return new MetricData(vo2, progress, vo2.format("%.0f"));
        }

        return new MetricData(0, 0.0, "—");
    }

    function getBodyBattery() {
        var info = ActivityMonitor.getInfo();

        // Some devices expose :bodyBattery, others don’t.
        if (info != null && (info has :bodyBattery) && info.bodyBattery != null) {
            var bb = info.bodyBattery;
            var progress = bb.toFloat() / 100.0;

            return new MetricData(bb, progress, bb.format("%d") + "%");
        }

        return new MetricData(0, 0.0, "—");
    }

    function getStress() {
        // Best: current stress from ActivityMonitor.getInfo() when available
        var info = ActivityMonitor.getInfo();
        if (info != null && (info has :stress) && info.stress != null) {
            var stress = info.stress; // usually 0..100
            var progress = stress.toFloat() / 100.0;
            if (progress > 1.0) { progress = 1.0; }
            if (progress < 0.0) { progress = 0.0; }

            return new MetricData(stress, progress, stress.format("%d"));
        }

        // Optional fallback: attempt SensorHistory if supported (guarded)
        // If unsupported on device/API, this will just skip.
        try {
            var hist = SensorHistory.getStressHistory({:period => 1});
            if (hist != null) {
                var sample = hist.next();
                if (sample != null && (sample has :stress) && sample.stress != null) {
                    var s = sample.stress;
                    var p = s.toFloat() / 100.0;
                    if (p > 1.0) { p = 1.0; }
                    if (p < 0.0) { p = 0.0; }
                    return new MetricData(s, p, s.format("%d"));
                }
            }
        } catch (e) {
            // ignore
        }

        return new MetricData(0, 0.0, "—");
    }

    function getHeartRate() {
        // Current HR is usually in ActivityMonitor.getInfo() as :currentHeartRate
        var info = ActivityMonitor.getInfo();
        if (info != null && (info has :currentHeartRate) && info.currentHeartRate != null) {
            var hr = info.currentHeartRate;

            var maxHR = 190; // reasonable default
            var profile = UserProfile.getProfile();
            if (profile != null && (profile has :maxHeartRate) && profile.maxHeartRate != null) {
                maxHR = profile.maxHeartRate;
            }

            var progress = hr.toFloat() / maxHR.toFloat();
            if (progress > 1.0) { progress = 1.0; }
            if (progress < 0.0) { progress = 0.0; }

            return new MetricData(hr, progress, hr.format("%d"));
        }

        return new MetricData(0, 0.0, "—");
    }

    function getRecovery() {
        var info = ActivityMonitor.getInfo();

        // Key often exists on newer models: :timeToRecovery (minutes)
        if (info != null && (info has :timeToRecovery) && info.timeToRecovery != null) {
            var minutesTotal = info.timeToRecovery;

            var hours = minutesTotal / 60;
            var minutes = minutesTotal % 60;

            // Lower recovery time is better (cap at 48h)
            var progress = 1.0 - (hours.toFloat() / 48.0);
            if (progress < 0.0) { progress = 0.0; }
            if (progress > 1.0) { progress = 1.0; }

            var formatted = (hours > 0) ? (hours.format("%d") + "h") : (minutes.format("%d") + "m");

            return new MetricData(minutesTotal, progress, formatted);
        }

        return new MetricData(0, 0.0, "—");
    }

    // Format large numbers with commas
    function formatNumber(num) {
        var str = num.format("%d");
        var len = str.length();

        if (len <= 3) {
            return str;
        }

        var result = "";
        var count = 0;

        for (var i = len - 1; i >= 0; i--) {
            if (count == 3) {
                result = "," + result;
                count = 0;
            }
            result = str.substring(i, i + 1) + result;
            count++;
        }

        return result;
    }
}