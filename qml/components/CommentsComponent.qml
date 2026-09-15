import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: commentItem
    width: parent.width
    height: commentBody.height + Theme.paddingLarge * 2
    contentHeight: height
    onClicked: commentsPage.replyTo(commentId, nickname, 0)

    function formatTime(value) {
        if (!value) return ""
        var date = new Date(value.replace("T", " "))
        var elapsed = Format.formatDate(date, Formatter.DurationElapsed)
        return elapsed || Format.formatDate(date, Formatter.Timepoint)
    }

    Column {
        id: commentBody
        width: parent.width - Theme.horizontalPageMargin * 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.paddingSmall

        Row {
            width: parent.width
            spacing: Theme.paddingMedium

            Image {
                width: Theme.iconSizeMedium
                height: width
                fillMode: Image.PreserveAspectFit
                source: avatar
                Image {
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../gfx/noavatar.png")
                    visible: parent.status === Image.Error
                }
            }

            Column {
                width: parent.width - Theme.iconSizeMedium - Theme.paddingMedium
                Label {
                    width: parent.width
                    text: nickname + (phone_model ? "  ·  " + phone_model : "")
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Elide
                }
                Label {
                    width: parent.width
                    text: commentItem.formatTime(posttime) + (floor ? "  " + floor : "")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeTiny
                }
            }
        }

        Label {
            width: parent.width
            text: content
            wrapMode: Text.WordWrap
            color: Theme.primaryColor
            textFormat: Text.AutoText
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            width: parent.width
            text: agree + "  " + against + "    点击回复"
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeTiny
        }

        Column {
            width: parent.width
            spacing: 1
            visible: replies && replies.length > 0

            Repeater {
                model: replies || []
                delegate: Rectangle {
                    width: parent.width
                    height: replyColumn.height + Theme.paddingMedium * 2
                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.18)

                    Column {
                        id: replyColumn
                        width: parent.width - Theme.paddingMedium * 2
                        anchors.centerIn: parent
                        spacing: Theme.paddingSmall

                        Label {
                            width: parent.width
                            text: modelData.nickname + (modelData.replyTo ? " 回复 " + modelData.replyTo : "")
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                        Label {
                            width: parent.width
                            text: modelData.content
                            wrapMode: Text.WordWrap
                            textFormat: Text.AutoText
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                        Label {
                            width: parent.width
                            text: commentItem.formatTime(modelData.posttime) +
                                  (modelData.floor ? "  " + modelData.floor : "") +
                                  "    赞 " + modelData.agree + "  踩 " + modelData.against
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeTiny
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mouse.accepted = true
                            commentsPage.replyTo(modelData.commentId, modelData.nickname, commentId)
                        }
                    }
                }
            }
        }
    }

    Separator {
        width: parent.width
        anchors.bottom: parent.bottom
        color: Theme.highlightColor
    }
}
