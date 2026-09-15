import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/main.js" as JS

Page {
    id: newspage
    allowedOrientations: Orientation.All
    property alias listmodel: listmodel
    property string nextCursor: ""
    property bool hasMore: true
    property bool loadingMore: false

    ListModel { id: listmodel }

    Connections {
        target: signalCenter
        onLoadFailed: newspage.loadingMore = false
    }

    function refresh() {
        nextCursor = ""
        hasMore = true
        loadingMore = false
        JS.loadNews(newspage, "0", true)
    }

    function loadMore() {
        if (loadingMore || !hasMore || nextCursor === "")
            return
        loadingMore = true
        JS.loadNews(newspage, nextCursor, false)
    }

    SilicaListView {
        anchors.fill: parent
        clip: true
        model: listmodel
        header: PageHeader { title: "IT之家" }

        PullDownMenu {
            MenuItem { text: "关于"; onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml")) }
            MenuItem { visible: appwindow.loggedIn; text: "注销（" + appwindow.nickname + "）"; onClicked: appwindow.logout() }
            MenuItem { visible: !appwindow.loggedIn; text: "登录"; onClicked: appwindow.openLogin() }
            MenuItem { text: "刷新"; onClicked: newspage.refresh() }
        }

        delegate: NewsListComponents { }
        VerticalScrollDecorator { }

        onAtYEndChanged: {
            if (atYEnd && count > 0)
                newspage.loadMore()
        }

        footer: Item {
            width: parent.width
            height: Theme.itemSizeLarge
            BusyIndicator {
                anchors.centerIn: parent
                running: newspage.loadingMore
                size: BusyIndicatorSize.Small
            }
            Label {
                anchors.centerIn: parent
                visible: !newspage.loadingMore && !newspage.hasMore && listmodel.count > 0
                text: "我们是有底线的"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        ViewPlaceholder {
            enabled: listmodel.count === 0 && !appwindow.loading
            text: "暂无资讯"
            hintText: "下拉刷新重试"
        }
    }

    Component.onCompleted: refresh()
}
