import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root;

    property int bh: Math.min(Theme.itemSizeHuge * 4, Screen.height);
    property int bw: Math.min(root.width - Theme.paddingSmall * 2, Theme.itemSizeHuge * 5);
    implicitHeight: bh;

    //var ww = Math.min(200, w), hh = Math.min(h * ww/w, 200);

    MouseArea {
        anchors.fill: img;
        onClicked: {
            img.playing = true;
        }
    }

    AnimatedImage {
        id: img;
        anchors.horizontalCenter: root.horizontalCenter;
        //width: Screen.width*3/4;
        width: bw;
        height: parent.height;
        fillMode: Image.PreserveAspectFit;
//        sourceSize.width: bw;
        source: content;
        asynchronous: true;
        playing: false
    }

    Image {
        anchors.centerIn: img;
        sourceSize.width: Theme.fontSizeMedium * 2
        source: "image://theme/icon-m-play";
        asynchronous: true;
        visible: !img.playing
    }
}
