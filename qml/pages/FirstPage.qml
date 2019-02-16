import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/main.js" as JS

Page {
    id: newspage
    property alias listmodel: listmodel
    property alias listView: listView
    property int latestNewsid:0
    allowedOrientations: Orientation.All

    ListModel{
        id: listmodel
    }

    XmlListModel {
        id: slideModel
        source: JS.getSlideUrl()
        query: "/rss/channel/item[contains(lower-case(child::opentype),'1')]"
        XmlRole { name: "linkurl"; query: "link/string()" }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "image"; query: "image/string()" }
        XmlRole { name: "opentype"; query: "opentype/string()" }
    }


    XmlListModel {
        id: xmlModel
        query: "/rss/channel/item"
        XmlRole { name: "newsid"; query: "newsid/number()" }
        XmlRole { name: "image"; query: "image/string()" }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "postdate"; query: "postdate/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "hitcount"; query: "hitcount/number()" }
        XmlRole { name: "commentcount"; query: "commentcount/string()" }
        XmlRole { name: "lapinid"; query: "lapinid/string()" }
        XmlRole { name: "topplat"; query: "topplat/string()" }
        onStatusChanged: {
            switch(status){
            case XmlListModel.Ready:
                signalCenter.loadFinished();
                for (var i=0; i<count; i++) {
                    var item = get(i);
                    if(item.lapinid){
                        continue;
                    }
                    listmodel.append({newsid: item.newsid,
                                        title: item.title,
                                        image: item.image,
                                        postdate: item.postdate,
                                        description: item.description,
                                        hitcount: item.hitcount,
                                        commentcount: item.commentcount
                                        });
                }
                break;
            case XmlListModel.Loading:
                signalCenter.loadStarted();
                break;
            case XmlListModel.Error:
                break;
//                signalCenter.loadFailed(errorString());
            default:
                console.log(status);
            }

        }

    }


    function loadMore(newsid){
        var url = JS.getMoreNews(newsid);
        xmlModel.source = url;
        xmlModel.reload();
    }




    SilicaListView{
        id: listView
        anchors.fill: parent
        width: parent.width
        clip: true
        header: SlidePage{
            bannermodel: slideModel
        }

        PullDownMenu {
            MenuItem {
                text: "关于"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
            }
            MenuItem {
                text: "刷新"
                onClicked: JS.getNewsList();
            }
        }
        model: listmodel
        delegate: NewsListComponents{}
        onDraggingChanged: {
            if (!dragging && !loading) {
                if (atYEnd) {
                    var newsid = listmodel.get(listmodel.count-1).newsid;
                    loadMore(newsid)
                }
            }
        }

        VerticalScrollDecorator {flickable: listView}

        ViewPlaceholder {
            enabled: listView.count == 0 && !PageStatus.Active
            text: "无结果，点击重试"
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    JS.getNewsList();
                }
            }
        }

    }

    Component.onCompleted: {
        JS.signalcenter = signalCenter
        JS.newsListPage = newspage;
        JS.getNewsList();
    }
}
