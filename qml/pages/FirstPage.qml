import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import "../js/main.js" as JS

Page {
    id: newspage
    property alias listmodel: listmodel
    property alias listView: listView
    allowedOrientations: Orientation.All

    ListModel{
        id: listmodel
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
                signalCenter.loadFinished();
                break;
            case XmlListModel.Loading:
                signalCenter.loadStarted();
                break;
            case XmlListModel.Error:
                signalCenter.loadFailed(errorString());
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
        clip: true
        header: PageHeader{
            title: "IT之家"
        }

        PullDownMenu {
            MenuItem {
                text: "刷新"
                onClicked: JS.getNewsList();
            }
        }
        model: listmodel
        delegate:
            BackgroundItem{
                id:showlist
                height:titleid.height+timeid.height+summaryid.height+Theme.paddingMedium*4
                width: parent.width
                Label{
                    id:titleid
                    text:title
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    font.bold:true;
                    anchors {
                        top:parent.top;
                        left: parent.left
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }

                Label{
                    id:summaryid
                    text: description
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    linkColor:Theme.primaryColor
                    maximumLineCount: 6
                    anchors {
                        top: titleid.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }
                Label{
                    id:timeid

                    text: "发布时间 : " +  fmtTime(postdate) //JS.humanedate(postdate)
                    //opacity: 0.7
                    font.pixelSize: Theme.fontSizeTiny
                    //font.italic: true
                    color: Theme.secondaryColor
                    //horizontalAlignment: Text.AlignRight
                    anchors {
                        top:summaryid.bottom
                        left: parent.left
                        topMargin: Theme.paddingMedium
                        leftMargin: Theme.paddingMedium
                    }
                }
                Label{
                    id:viewcount
                    text:"评论 : "+commentcount+" / 浏览 : "+hitcount
                    //opacity: 0.7
                    font.pixelSize: Theme.fontSizeTiny
                    //font.italic: true
                    color: Theme.secondaryColor
                    //horizontalAlignment: Text.AlignRight
                    anchors {
                        top:summaryid.bottom
                        right: parent.right
                        topMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                }
                Separator {
                    visible:(index > 0?true:false)
                    width:parent.width;
                    //alignment:Qt.AlignHCenter
                    color: Theme.highlightColor
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("NewsDetail.qml"),{
                                       "newsid":newsid,
                                       "newstitle":title
                                   });
                }
        }

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
