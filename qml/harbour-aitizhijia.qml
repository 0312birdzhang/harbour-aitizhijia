import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0
import io.thp.pyotherside 1.3

import "pages"
import "js/main.js" as JS

ApplicationWindow
{
    id: appwindow
    property bool loading: false
    property string appname: "挨踢之家"
    initialPage: config.accepted ? firstpage : discclaimer
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ConfigurationGroup{
        id: config
        path: "/app/xyz.birdzhang.aitizhijia"
        property bool accepted: false
    }

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
    Component {
        id: firstpage
        FirstPage {
        }
    }
    Component{
        id:discclaimer
        DisclaimerDialog{
            acceptDestination: firstpage
            acceptDestinationAction: PageStackAction.Replace
        }
    }

    Python{
        id: py
        Component.onCompleted: {
           addImportPath('./py');
           py.importModule('main', function () {

           });
        }

        function getHotComments(newsid){
            call('main.get_hot_comment',[newsid],function(result){
                console.log(result)
                if(result && result.length > 0){
                    for(var i=0; i < result.length; i++){
                        hostModel.append(result[i])
                    }
                }
            });
        }
    }

    Component.onCompleted: {
        JS.signalcenter = signalCenter
    }
}
