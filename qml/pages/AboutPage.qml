import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    id: aboutPage
    //allowedOrientations: Orientation.All
    SilicaFlickable {
        id: about
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: appwindow.pageContentWidth
        contentHeight: aboutRectangle.height

        VerticalScrollDecorator { flickable: about }

        Column {
            id: aboutRectangle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader {
                title: "关于"
            }

            Image {
                source: "image://theme/harbour-aitizhijia"
                width: parent.width
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
            }

            Label {
                text:  appwindow.appname
                horizontalAlignment: Text.Center
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SectionHeader {
                text: "描述"
            }

            Label {
                textFormat: Text.RichText;
                text: "首先感谢梦梦（@旺仔狂魔）提供的图标.<br/> "
                       + "本软件是 www.ithome.com 的第三方实现，界面与数据接口基于 KaiOS 版本重写。"
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader {
                text: "许可证"
            }

            Label {
                text: qsTr("Copyright © by") + " 0312birzhang\n" + qsTr("License") + ": GPL v2"
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader {
                text: "项目源码"
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                textFormat: Text.RichText;
                text: "<style>a:link { color: " + Theme.highlightColor
                      + "; }</style><a href=\"https://github.com/0312birdzhang/harbour-aitizhijia\">https://github.com/0312birdzhang/harbour-aitizhijia\</a>"
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeTiny

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }
            SectionHeader {
                text: "改动日志"
            }
            Label {
                text:"version 0.1<br/>
                        初始版本" +
                    "<br/>" +
                     "version 0.2<br/>
                        资讯详情由webview更改为原生显示<br/>" +
                     "version 0.3.0<br/>
                        使用 JSON 接口重写资讯、正文和评论浏览<br/>" +
                     "release 2<br/>
                        支持账号登录、注销和发表评论<br/>" +
                     "release 3<br/>
                        修复评论、登录及头像接口的 HTTP 302 错误<br/>" +
                     "version 0.4.0<br/>
                        支持手机验证码登录、楼中楼显示及指定楼层回复<br/>" +
                     "version 0.4.0 release 2<br/>
                        新增个人主页，显示头像、昵称、等级、经验和金币<br/>" +
                     "version 0.4.0 release 3<br/>
                        修复用户中心图标，并接入官方签到规则<br/>" +
                     "version 0.4.0 release 4<br/>
                        修复首次取消退出，支持屏幕旋转和大屏布局<br/>" +
                     "version 0.4.0 release 5<br/>
                        重做首次声明操作，并修复页面方向继承"
                width: parent.width - Theme.paddingLarge * 2
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
