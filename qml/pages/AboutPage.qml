import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    id: aboutPage
    SilicaFlickable {
        id: about
        anchors.fill: parent
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
                text:  "AiTi之家 0.1"
                horizontalAlignment: Text.Center
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SectionHeader {
                text: "描述"
            }

            Label {
                textFormat: Text.RichText;
                text: "感谢梦梦（@旺仔狂魔）提供的图标.<br/> "
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
                        初始版本"
                width: parent.width - Theme.paddingLarge * 2
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
