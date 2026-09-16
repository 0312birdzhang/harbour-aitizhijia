import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/main.js" as JS

Page {
    id: userCenter
    //allowedOrientations: Orientation.All
    property bool refreshing: false
    property string statusText: ""
    property bool showUserFunctions: false

    function refreshProfile() {
        refreshing = true
        statusText = ""
        JS.refreshUserProfile(userCenter)
    }

    function profileLoaded() {
        refreshing = false
        statusText = "资料已更新"
    }

    function profileLoadFailed(message) {
        refreshing = false
        statusText = message
    }

    function notImplemented(name) {
        appwindow.showMessage(name + "功能暂未完成")
    }

    function showSignInRules() {
        appwindow.showMessage("新版 IT之家达到每日阅读条件后会自动签到")
        Qt.openUrlExternally("https://my.ruanmei.com/usercenter/h5/signrules.htm?hidemenu=1")
    }

    SilicaFlickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: appwindow.pageContentWidth
        contentHeight: contentColumn.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem { text: "刷新个人资料"; onClicked: userCenter.refreshProfile() }
        }

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: "个人主页" }

            Image {
                width: Theme.itemSizeHuge
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                source: appwindow.avatar
                fillMode: Image.PreserveAspectCrop
                asynchronous: true

                Image {
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../gfx/noavatar.png")
                    visible: parent.status === Image.Error || !appwindow.avatar
                    fillMode: Image.PreserveAspectFit
                }
            }

            Label {
                width: parent.width - Theme.horizontalPageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: appwindow.nickname || appwindow.username
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                truncationMode: TruncationMode.Elide
            }

            Label {
                width: parent.width - Theme.horizontalPageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: "等级 LV" + appwindow.rank +
                      (appwindow.rankDays ? "  ·  已加入 " + appwindow.rankDays + " 天" : "")
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
            }

            ProgressBar {
                width: parent.width
                label: "经验 " + appwindow.experience +
                       (appwindow.remainExperience > 0 ? "（距升级还需 " + appwindow.remainExperience + "）" : "")
                minimumValue: 0
                maximumValue: Math.max(1, appwindow.experience + appwindow.remainExperience)
                value: appwindow.experience
            }

            Label {
                width: parent.width
                text: "金币 " + appwindow.coins
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: userCenter.refreshing
                size: BusyIndicatorSize.Small
            }

            Label {
                width: parent.width
                visible: statusText !== ""
                text: statusText
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
            }

            SectionHeader {
                visible: userCenter.showUserFunctions
                text: "我的功能"
            }

            Grid {
                visible: userCenter.showUserFunctions
                width: parent.width
                columns: 2

                UserActionItem {
                    title: "签到"
                    iconSource: "image://theme/icon-m-date"
                    fallbackText: "签"
                    onTriggered: userCenter.showSignInRules()
                }
                UserActionItem {
                    title: "已回复评论"
                    iconSource: "image://theme/icon-m-message"
                    fallbackText: "评"
                    onTriggered: userCenter.notImplemented(title)
                }
                UserActionItem {
                    title: "我的帖子"
                    iconSource: "image://theme/icon-m-document"
                    fallbackText: "帖"
                    onTriggered: userCenter.notImplemented(title)
                }
                UserActionItem {
                    title: "我的收藏"
                    iconSource: "image://theme/icon-m-favorite"
                    fallbackText: "藏"
                    onTriggered: userCenter.notImplemented(title)
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "退出登录"
                onClicked: {
                    appwindow.logout()
                    pageStack.pop()
                }
            }
        }

        VerticalScrollDecorator { }
    }

    Component.onCompleted: refreshProfile()
}
