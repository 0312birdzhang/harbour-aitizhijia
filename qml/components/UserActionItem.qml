import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: actionItem
    width: parent ? parent.width / 2 : Screen.width / 2
    height: Theme.itemSizeHuge
    property string title
    property string iconSource
    property string fallbackText
    signal triggered
    onClicked: triggered()

    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingSmall

        Item {
            width: Theme.iconSizeMedium
            height: width
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: actionIcon
                anchors.fill: parent
                source: actionItem.iconSource
            }
            Label {
                anchors.fill: parent
                visible: !actionItem.iconSource || actionIcon.status === Image.Error
                text: actionItem.fallbackText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: actionItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
            }
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: actionItem.title
            color: actionItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
