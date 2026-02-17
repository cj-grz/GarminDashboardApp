using Toybox.Application;
using Toybox.WatchUi;

class DashboardWatchFaceApp extends Application.AppBase {
    
    function initialize() {
        AppBase.initialize();
    }
    
    function onStart(state) {
    }
    
    function onStop(state) {
    }
    
    function getInitialView() {
        return [new DashboardWatchFaceView()];
    }
}
