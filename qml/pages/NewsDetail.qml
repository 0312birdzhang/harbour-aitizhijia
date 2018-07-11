import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import "../js/main.js" as JS

Page {
    id: detailpage
    property string newstitle
    property int newsid

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

            Label{
                id:contentbody
                opacity: 0.8
                textFormat: Text.RichText
                text:detail.replace(/<img/g, '<img width="100%"')
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                linkColor:Theme.primaryColor
                font.letterSpacing: 2;
                anchors{
                    left:parent.left
                    right:parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                onLinkActivated: {
                    remorse.execute("即将打开链接...",function(){
                        Qt.openUrlExternally(link);
                    },3000);
                    
                }
            }

        }
    }
}
