import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/main.js" as JS

Page {
    id: newspage
    property alias listmodel: listmodel
    property alias listView: listView
    allowedOrientations: Orientation.All

    ListModel{
        id: listmodel
    }

    XmlListModel {
        id: slideModel
        source: JS.getSlideUrl()
        query: "/rss/channel/item"
        XmlRole { name: "newsid"; query: "link/number()" }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "image"; query: "image/string()" }
//        onStatusChanged: {
//            if(status == XmlListModel.Ready){

//                slidePage.model = slideModel
//            }
//        }
    }


    XmlListModel {
        id: xmlModel
        query: "/rss/channel/item"
        XmlRole { name: "newsid"; query: "newsid/number()" }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "postdate"; query: "postdate/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "hitcount"; query: "hitcount/number()" }
        XmlRole { name: "commentcount"; query: "commentcount/number()" }
        onStatusChanged: {
            switch(status){
            case XmlListModel.Ready:
                signalCenter.loadFinished();
                for (var i=0; i<count; i++) {
                    var item = get(i);
                    listmodel.append({newsid: item.newsid,
                                        title: item.title,
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

    function fmtTime(postdate) {
        if(postdate.indexOf("T")){
            postdate = postdate.replace("T"," ");
        }
        var month = parseInt(postdate.split("-")[1]);
        if( month < 10){
            postdate = postdate.replace("-"+month+"-", "-0"+month+"-");
        }
        var txt = Format.formatDate(new Date(postdate), Formatter.Timepoint)
        var elapsed = Format.formatDate(new Date(postdate), Formatter.DurationElapsed)
        return elapsed ? elapsed : txt
    }

    function loadMore(newsid){
        var url = JS.getMoreNews(newsid);
        xmlModel.source = url;
        xmlModel.reload();
    }




    SilicaListView{
        id: listView
        anchors.fill: parent
//        anchors {
//            top: parent.top
//            left: parent.left
//            right: parent.right
//        }
        width: parent.width
        clip: true
        header: SlidePage{
            model: slideModel
        }





        PullDownMenu {
            MenuItem {
                text: "刷新"
                onClicked: JS.getNewsList();
            }
        }
        model: listmodel
        delegate: NewsListComponents{}

        footer: Component{

            Item {
                id: loadMoreID
                anchors {
                    left: parent.left;
                    right: parent.right;
                }
                height: Theme.itemSizeMedium
                Row {
                    id:footItem
                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                   
                    Button{
                        text: "加载更多..."
                        onClicked: {
                            var newsid = listmodel.get(listmodel.count-1).newsid;
                            loadMore(newsid)
                        }
                    }
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
