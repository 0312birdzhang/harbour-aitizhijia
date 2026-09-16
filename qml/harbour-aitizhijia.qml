import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0

import "pages"
import "js/main.js" as JS

ApplicationWindow
{
    id: appwindow
    property bool loading: false
    property string appname: "AiTi之家"
    property real pageContentWidth: Math.min(width, Theme.itemSizeHuge * 8)
    property alias userhash: config.userhash
    property alias username: config.username
    property alias nickname: config.nickname
    property alias userid: config.userid
    property alias avatar: config.avatar
    property alias rank: config.rank
    property alias experience: config.experience
    property alias remainExperience: config.remainExperience
    property alias coins: config.coins
    property alias rankDays: config.rankDays
    property bool loggedIn: userhash !== ""
    initialPage: config.accepted ? firstpage : discclaimer
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    ConfigurationGroup{
        id: config
        path: "/app/xyz.birdzhang.aitizhijia"
        property bool accepted: false
        property string userhash: ""
        property string username: ""
        property string nickname: ""
        property int userid: 0
        property string avatar: ""
        property int rank: 0
        property int experience: 0
        property int remainExperience: 0
        property int coins: 0
        property string rankDays: ""
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
        }
    }

    function formathtml(html) {
        html = html.replace(/<a href=/g,"<a style='color:" + Theme.highlightColor + "' target='_blank' href=");
        html = html.replace(/<a class=/g,"<a style='color:" + Theme.highlightColor + "' target='_blank' class=");
        html = html.replace(/<p>/g,"<p style='text-indent:24px'>");
//        html = html.replace(/<img\ssrc=\"\/assets\//g, "<img src=\""+siteUrl+"/assets/");
        html = html.replace(/<p style='text-indent:24px'><img/g,"<p><img");
        html = html.replace(/<p style='text-indent:24px'><a [^<>]*href=\"([^<>"]*)\".*?><img/g,"<p><a href='$1'><img");
        html = html.replace(/&#x2F;/g,"/");
        return html;
    }

    function showMessage(message) {
        notification.show(message)
    }

    function quitApplication() {
        Qt.quit()
    }

    function acceptDisclaimer() {
        config.accepted = true
        pageStack.replace(firstpage)
    }

    function openLogin() {
        pageStack.push(Qt.resolvedUrl("pages/LoginDialog.qml"))
    }

    function logout() {
        userhash = ""
        username = ""
        nickname = ""
        userid = 0
        avatar = ""
        rank = 0
        experience = 0
        remainExperience = 0
        coins = 0
        rankDays = ""
        notification.show("已注销")
    }

    function openComment(newsid, refreshTarget, parentCommentId, rootCommentId, replyTo) {
        if (!loggedIn) {
            openLogin()
            return
        }
        pageStack.push(Qt.resolvedUrl("pages/CommentDialog.qml"), {
                           "newsid": newsid,
                           "refreshTarget": refreshTarget,
                           "parentCommentId": parentCommentId || 0,
                           "rootCommentId": rootCommentId || 0,
                           "replyTo": replyTo || ""
                       })
    }

    function splitContent(topic_content, parent){
        return JS.splitContent(topic_content, parent);
    }

    function openLink(link) {
        var linklist=link.split(".");
        var linktype=linklist[linklist.length -1];
        if(linktype =="png" ||linktype =="jpg"||linktype =="jpeg"||linktype =="gif"||linktype =="ico"||linktype =="svg"){
            pageStack.push(Qt.resolvedUrl("./components/ImagePage.qml"),{"localUrl":link});
        // }else if (/https:\/\/m\.ithome\.com\/uid\/[0-9]{1,}/.exec(link)) {
        //     var uidlink = /https:\/\/sailfishos\.club\/uid\/[0-9]{1,}/.exec(link)
        //     var uid = /[0-9]{1,}/.exec(uidlink[0].split("/"))[0];
        //     //to user profile page
        //     toUserInfoPage(uid);
        // }else if (/https:\/\/m\.ithome\.com\/topic\/[0-9]{1,}/.exec(link)) {
        //     var topiclink = /https:\/\/sailfishos\.club\/topic\/[0-9]{1,}/.exec(link)
        //     var tid = /[0-9]{1,}/.exec(topiclink[0].split("/"))[0];
        //     //to topic page
        //     console.log("to topic page, tid:"+ tid)
        //     pageStack.push(Qt.resolvedUrl("pages/TopicPage.qml"),{
        //                                "tid": tid
        //                            });
        // }else if (/https:\/\/sailfishos\.club\/post\/[0-9]{1,}/.exec(link)) {
        //     var postlink = /https:\/\/sailfishos\.club\/post\/[0-9]{1,}/.exec(link)
        //     var pid = /[0-9]{1,}/.exec(postlink[0].split("/"))[0];
        //     console.log("pid:"+pid); //TODO
        //     //ddd

        }else{
            remorse.execute(qsTr("Starting open link..."),function(){
                Qt.openUrlExternally(link);
            },3000);
        }
    }

    Component.onCompleted: {
        JS.app = appwindow;
        JS.signalcenter = signalCenter
    }
}
