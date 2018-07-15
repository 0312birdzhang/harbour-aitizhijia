import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: disclaimer
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: disclaimercolumn.height + disclaimercolumn.spacing

        Column {
            id: disclaimercolumn
            width: parent.width
            spacing: Theme.paddingSmall

            DialogHeader {
                title: "免责声明"
            }

            Label {
                property string disclaimertext: "本软件接口来自网络，对于本软件的内容真实性与否本人不负责，"+
                                                "对于在使用过程中对您造成的影响本人不负责。禁止发布含违法法律、行政法规的内容等。"+
                                                "本软件承诺不收集您的隐私信息，你使用本软件即视为你已阅读并同意受本协议的约束。"

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.paddingMedium * 2
                wrapMode: Text.WordWrap
                text: disclaimertext
            }
        }
    }
    onAccepted: config.accepted = true
    onRejected: Qt.quit();
}
