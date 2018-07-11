import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/main.js" as JS

Page {
    id: newspage
    property alias listmodel: listmodel
    property alias listView: listView
    property int page : 0
    allowedOrientations: Orientation.All

    ListModel{
        id: listmodel
    }

    onPageChanged: {
        console.log("page changed:"+page)
        JS.getNewsList(page)
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
                text: qsTr("Refresh")
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
                    text: "发布时间 : "+ JS.humanedate(postdate)
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
                visible: false
                anchors {
                    left: parent.left;
                    right: parent.right;
                }
                height: Theme.itemSizeMedium
                Row {
                    id:footItem
                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    Button {
                        text: "上一页"
                        visible: page > 0
                        onClicked: {
                            page = listmodel.get(0).newsid;
                        }
                    }
                    Button{
                        text:"下一页"
                        onClicked: {
                            page = listmodel.get(-1).newsid;
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
                    JS.getNewsList(page);
                }
            }
        }

    }


    Component.onCompleted: {
        JS.signalcenter = signalCenter
        JS.newsListPage = newspage;
        JS.getNewsList(page);
    }
}
