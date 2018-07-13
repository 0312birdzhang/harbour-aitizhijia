import QtQuick 2.0
import Sailfish.Silica 1.0

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
        pageStack.push(Qt.resolvedUrl("../pages/NewsDetail.qml"),{
                           "newsid":newsid,
                           "newstitle":title
                       });
    }
}
