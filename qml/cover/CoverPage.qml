import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
//    Label {
//        id: label
//        anchors.centerIn: parent
//        text: "AiTiHome"
//    }
    Image {
        id: coverimg
        anchors{
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        width: parent.width
        height: width
        source: "../gfx/ithome.png"
    }
}
