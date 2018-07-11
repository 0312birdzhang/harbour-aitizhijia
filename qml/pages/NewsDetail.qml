import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/main.js" as JS

Page {
    id: detailpage
    property string newstitle
    property int newsid

    XmlListModel {
        id: xmlModel
        query: "/rss/channel/item"
        XmlRole { name: "newssource"; query: "newssource/string()" }
        XmlRole { name: "newsauthor"; query: "newsauthor/string()" }
        XmlRole { name: "detail"; query: "detail/string()" }
        XmlRole { name: "zeren"; query: "z/string()" }

    }
    //

    SilicaListView{
        id: listView
        model: xmlModel
        header: PageHeader {
            title: newstitle
            _titleItem.font.pixelSize: Theme.fontSizeSmall
        }
        delegate:Column{
            
            Label{
                id:detailtime
                text:"稿源 : " + newssource
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

            Rectangle {
                id:fromMsg_bg
                width:parent.width
                height: fromMsg.height + Theme.paddingMedium*2
                anchors{
                    left: parent.left;
                    right: parent.right;
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                radius: 5;
                color: "#1affffff"
                Label{
                    id:fromMsg
                    width: parent.width
                    text: newsauthor
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeExtraSmall
                    linkColor:Theme.primaryColor
                    color: Theme.secondaryColor
                    elide: Text.ElideMiddle
                    wrapMode: Text.WordWrap
                    font.letterSpacing: 2;
                    anchors.centerIn: parent
                }
            }

            Label{
                id:contentbody
                opacity: 0.8
                textFormat: Text.RichText //openimg == 1 ? Text.RichText : Text.StyledText;
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

            Label{
                id:detaileditor
                text:"   [ 责任编辑 : " + zeren + " ]"
                anchors{
                    right:parent.right
                    rightMargin: Theme.paddingMedium
                }
                font.pixelSize: Theme.fontSizeExtraSmall
                truncationMode: TruncationMode.Fade
                wrapMode: Text.WordWrap
            }
        }
    }


    Component.onCompleted: {
        JS.newsDetailPage = detailpage;
        JS.getNewsDetail(newsid);
    }
}
