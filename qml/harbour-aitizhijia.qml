import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

import "pages"
import "js/main.js" as JS

ApplicationWindow
{
    id: appwindow
    property bool loading: false
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Notification{
        id: notification
        function show(message, icn) {
            replacesId = 0
            previewSummary = ""
            previewBody = message
            icon = icn ? icn : ""
            publish()
        }

        function showPopup(title, message, icn) {
            replacesId = 0
            previewSummary = title
            previewBody = message
            icon = icn
            publish()
        }

        expireTimeout: 3000
    }
    Timer{
        id:processingtimer;
        interval: 40000;
        onTriggered: signalCenter.loadFailed(qsTr("Request timeout"));
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: loading
        size: BusyIndicatorSize.Large
    }

    RemorsePopup{
        id: remorse
    }

    Connections{
        target: signalCenter;
        onLoadStarted:{
            appwindow.loading=true;
            processingtimer.restart();
        }
        onLoadFinished:{
            appwindow.loading=false;
            processingtimer.stop();
        }
        onLoadFailed:{
            appwindow.loading=false;
            processingtimer.stop();
            notification.show(errorstring);
        }
    }

    SignalCenter{
        id: signalCenter;
    }

    Component.onCompleted: {
        JS.signalcenter = signalCenter
    }
}
