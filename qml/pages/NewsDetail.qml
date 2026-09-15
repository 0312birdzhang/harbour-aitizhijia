import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/main.js" as JS

Page {
    id: detailpage
    property string newstitle
    property int newsid
    property string postdate
    property int commentcount: 0
    property string sourceName: ""
    property string authorName: ""
    property string editorName: ""
    property var articleModel: null
    property bool detailReady: false

    SilicaListView {
        anchors.fill: parent
        model: detailpage.articleModel

        PullDownMenu {
            MenuItem {
                text: "发表评论"
                onClicked: appwindow.openComment(detailpage.newsid, null)
            }
            MenuItem {
                text: "查看评论（" + detailpage.commentcount + "）"
                onClicked: pageStack.push(Qt.resolvedUrl("CommentsPage.qml"), {"newsid": detailpage.newsid})
            }
        }

        header: Column {
            width: parent.width
            PageHeader { title: detailpage.newstitle }
            Label {
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: detailpage.postdate + (detailpage.sourceName ? "  " + detailpage.sourceName : "") +
                      (detailpage.authorName ? "（" + detailpage.authorName + "）" : "")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Item { width: 1; height: Theme.paddingMedium }
        }

        delegate: Loader {
            width: parent.width
            source: Qt.resolvedUrl("../components/" + type + "Delegate.qml")
        }

        footer: Label {
            width: parent.width
            height: detailpage.detailReady ? Theme.itemSizeLarge : 0
            visible: detailpage.detailReady
            text: "我们是有底线的"
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ViewPlaceholder {
            enabled: !detailpage.detailReady && !appwindow.loading
            text: "正文加载失败"
            hintText: "返回后重试"
        }
        VerticalScrollDecorator { }
    }

    Component.onCompleted: JS.loadNewsDetail(detailpage, newsid)
}
