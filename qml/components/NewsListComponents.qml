import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem{
    id:showlist
    height: newsImage.height + Theme.paddingLarge * 2
    width: parent.width


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

    Image{
        id: newsImage
        source: image
        anchors{
            left: parent.left
            top: parent.top
            margins: Theme.paddingMedium
        }
    }

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
            left: newsImage.right
            right: parent.right
            topMargin: Theme.paddingMedium
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
    }

    Label{
        id:timeid
        text: topplat ? "置顶" : "发布时间 : " +  fmtTime(postdate)
        font.pixelSize: Theme.fontSizeTiny
        color: topplat ? Theme.highlightColor : Theme.secondaryColor
        anchors {
            bottom: parent.bottom
            left: newsImage.right
            bottomMargin: Theme.paddingMedium
            leftMargin: Theme.paddingMedium
        }
    }
    Label{
        id:viewcount
        text: commentcount? ("评论 : "+commentcount+" / 浏览 : "+hitcount):""
        //opacity: 0.7
        font.pixelSize: Theme.fontSizeTiny
        //font.italic: true
        color: Theme.secondaryColor
        //horizontalAlignment: Text.AlignRight
        anchors {
            bottom: parent.bottom
            right: parent.right
            bottomMargin: Theme.paddingMedium
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
