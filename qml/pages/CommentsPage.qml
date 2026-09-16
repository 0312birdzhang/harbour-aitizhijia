import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/main.js" as JS

Page {
    id: commentsPage
    //allowedOrientations: Orientation.All
    property int newsid
    property alias commentModel: commentModel
    property string nextCursor: ""
    property bool hasMore: true
    property bool loadingMore: false

    ListModel { id: commentModel }

    Connections {
        target: signalCenter
        onLoadFailed: commentsPage.loadingMore = false
    }

    function loadMore() {
        if (loadingMore || !hasMore || nextCursor === "")
            return
        loadingMore = true
        JS.loadComments(commentsPage, newsid, nextCursor, false)
    }

    function refreshComments() {
        nextCursor = ""
        hasMore = true
        loadingMore = false
        JS.loadComments(commentsPage, newsid, "", true)
    }

    function replyTo(commentId, nickname, rootId) {
        appwindow.openComment(newsid, commentsPage, commentId, rootId, nickname)
    }

    SilicaListView {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: appwindow.pageContentWidth
        model: commentModel
        header: PageHeader { title: "评论" }
        PullDownMenu {
            MenuItem { text: "发表评论"; onClicked: appwindow.openComment(commentsPage.newsid, commentsPage) }
            MenuItem { text: "刷新"; onClicked: commentsPage.refreshComments() }
        }
        delegate: CommentsComponent { }
        VerticalScrollDecorator { }
        onAtYEndChanged: if (atYEnd && count > 0) commentsPage.loadMore()

        footer: Item {
            width: parent.width
            height: Theme.itemSizeLarge
            BusyIndicator {
                anchors.centerIn: parent
                running: commentsPage.loadingMore
                size: BusyIndicatorSize.Small
            }
            Label {
                anchors.centerIn: parent
                visible: !commentsPage.loadingMore && !commentsPage.hasMore && commentModel.count > 0
                text: "我们是有底线的"
                color: Theme.secondaryColor
            }
        }

        ViewPlaceholder {
            enabled: commentModel.count === 0 && !appwindow.loading
            text: "暂无评论"
            hintText: "稍后再来看吧"
        }
    }

    Component.onCompleted: refreshComments()
}
