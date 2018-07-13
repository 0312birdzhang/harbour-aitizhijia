import QtQuick 2.0
import Sailfish.Silica 1.0

Item{
    property alias model:banner.model
    width: parent.width
    height: banner.height + pageHeader.height
    anchors{
        left:parent.left
        right:parent.right
    }
    PageHeader{
        id: pageHeader
        title: "挨踢之家"
        anchors.right: parent.right
    }
    PathView {
        z:10
        id: banner;
        anchors.top: pageHeader.bottom
        width: parent.width;
        height: isLandscape?Screen.height/5.5:Screen.height/4
        preferredHighlightBegin: 0.5;
        preferredHighlightEnd: 0.5;
        path: Path {
            startX: isLandscape?(-banner.width*banner.count/4 + banner.width/4):(-banner.width*banner.count/2 + banner.width/2)
            startY: banner.height/2;
            PathLine {
                x: isLandscape?(banner.width*banner.count/4 + banner.width/4 ):(banner.width*banner.count/2 + banner.width/2)
                y: banner.height/2;
            }
        }

        clip: true
        delegate: Item {
            implicitWidth: isLandscape?banner.width/2:banner.width;
            implicitHeight: banner.height;
            clip:true
            Image{
                anchors{
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }
                source: image
                width: parent.width
                height: parent.height
            }

            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: mouseArea.pressed ? 0.3 : 0;
            }
            MouseArea {
                id: mouseArea;
                anchors.fill: parent;
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../pages/NewsDetail.qml"),{
                                   "newsid":newsid,
                                   "newstitle": title
                               });
                }
            }
        }
        Timer {
            running: Qt.application.active && banner.count > 1 && !banner.moving
            interval: 3000;
            repeat: true;
            onTriggered: banner.incrementCurrentIndex();
        }
    }
    Rectangle{
        z:8
        anchors.top:banner.bottom
        //            opacity: view.contentY/banner.height > 1 ? 0 : 1-view.contentY/banner.height;
        //            visible: opacity>0.0;
        width: parent.width;
        height: isLandscape?Screen.height/10:Screen.height/4/2
        gradient: Gradient {
            GradientStop { position: 0; color: "#08202c" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }
    Row{
        z:11
        anchors.left: parent.left;
        anchors.bottom: banner.bottom
        //            opacity: view.contentY/banner.height > 1 ? 0 : 1-view.contentY/banner.height;
        //            visible: opacity>0.0;
        Repeater{
            model: banner.count
            Rectangle{
                width:  isLandscape?Screen.width/banner.count*2:Screen.width/banner.count
                height: Theme.paddingSmall
                color: banner.currentIndex==index?"#22ffffff":"#44000000"
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        banner.currentIndex=index;
                    }
                }
            }
        }
    }
}
