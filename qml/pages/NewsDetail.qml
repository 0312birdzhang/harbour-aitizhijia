import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0

import "../components"
import "../js/main.js" as JS

Page {
    id: detailpage
    property string newstitle
    property int newsid
    property alias relatedmodel: relatedmodel

    ListModel{
        id: relatedmodel
    }

    XmlListModel {
        id: xmlModel
        source: JS.newsdetail(newsid)
        query: "/rss/channel/item"
        XmlRole { name: "newssource"; query: "newssource/string()" }
        XmlRole { name: "newsauthor"; query: "newsauthor/string()" }
        XmlRole { name: "detail"; query: "detail/string()" }
        XmlRole { name: "zeren"; query: "z/string()" }
        onStatusChanged: {
            switch(status){
            case XmlListModel.Ready:
                listView.model = xmlModel;
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

    SilicaListView{
        id: listView
        anchors.fill: parent
        width: parent.width
        model: xmlModel
        PullDownMenu {
            MenuItem {
                text: "查看评论"
                onClicked: pageStack.push(Qt.resolvedUrl("CommentsPage.qml"),{"newsid":newsid});
            }
        }
        header: PageHeader {
            title: newstitle
            _titleItem.font.pixelSize: Theme.fontSizeSmall
        }
        delegate:Column{
            width: parent.width
            spacing: Theme.paddingMedium
            Label{
                id:detailtime
                text:"来源: " + newssource + "   作者:" + newsauthor + "  责编:"+zeren
                anchors{
                    left:parent.left
                    right:parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                horizontalAlignment:Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                truncationMode: TruncationMode.Fade
                wrapMode: Text.WordWrap

            }

            Column{
                id: contentLabel
                width: parent.width;
                spacing: Theme.paddingSmall
                anchors{
                    left:parent.left
                    right:parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                Repeater {
                    model: splitContent(detail.replace(/<img/g, '<img width="'+ (parent.width - Theme.paddingLarge)+'"'), listView)
                    Loader {
                        anchors {
                            left: parent.left; right: parent.right;
                            margins: Theme.paddingSmall;
                        }
                        source: Qt.resolvedUrl("../components/" +type + "Delegate.qml");
                    }
                }
            }

            // Label{
            //     id:contentbody
            //     opacity: 0.8
            //     textFormat: Text.RichText
            //     text:detail.replace(/<img/g, '<img width="'+ (parent.width - Theme.paddingLarge)+'"')
            //     font.pixelSize: Theme.fontSizeExtraSmall
            //     wrapMode: Text.WordWrap
            //     linkColor:Theme.primaryColor
            //     font.letterSpacing: 2;
            //     anchors{
            //         left:parent.left
            //         right:parent.right
            //         leftMargin: Theme.paddingMedium
            //         rightMargin: Theme.paddingMedium
            //     }
            //     onLinkActivated: {
            //         remorse.execute("即将打开链接...",function(){
            //             Qt.openUrlExternally(link);
            //         },3000);
                    
            //     }
            // }

        }

        footer: Component{
            Item {
                anchors {
                    left: parent.left;
                    right: parent.right;
                }
                height: relatedCol.height
                width: parent.width
                Column{
                    id: relatedCol
                    width: parent.width
                    Item{
                        width: 1;
                        height: Theme.itemSizeMedium
                    }

//                    Label {
//                        text: "相关文章"
//                        color: Theme.highlightColor
//                        font.pixelSize: Theme.fontSizeMedium
//                        anchors{
//                            right: parent.right
//                            margins: Theme.paddingLarge
//                        }
//                    }
                    ExpandingSectionGroup {
                        currentIndex: -1
                        ExpandingSection {
                            id: section
                            title: "相关文章"
                            content.sourceComponent: Column {
                                width: section.width
                                Repeater{
                                    model: relatedmodel
                                    delegate: NewsListComponents{

                                    }
                                }
                            }
                        }

                    }

                }
            }
        }
    }
    Component.onCompleted: {
        JS.signalcenter = signalCenter;
        JS.newsDetailPage = detailpage;
        JS.getRelated(newsid)
    }
    Component.onDestruction: {
        appwindow.loading = false;
    }
}
