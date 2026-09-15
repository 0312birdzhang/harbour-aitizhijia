import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/main.js" as JS

Dialog {
    id: commentDialog
    property int newsid
    property var refreshTarget: null
    property int parentCommentId: 0
    property int rootCommentId: 0
    property string replyTo: ""
    canAccept: commentField.text.trim().length > 0

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: commentColumn.height

        Column {
            id: commentColumn
            width: parent.width

            DialogHeader {
                title: parentCommentId ? "回复 " + replyTo : "发表评论"
                acceptText: "发布"
            }

            TextArea {
                id: commentField
                width: parent.width
                label: "评论内容"
                placeholderText: label
                focus: true
            }

            Label {
                width: parent.width - Theme.horizontalPageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: "正在以“" + appwindow.nickname + "”发表评论。内容可能需要审核后显示。"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }
        }
    }

    onAccepted: {
        var target = refreshTarget
        JS.submitComment(newsid, commentField.text.trim(), parentCommentId, rootCommentId, function() {
            if (target && target.refreshComments)
                target.refreshComments()
        })
    }
}
