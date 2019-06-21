import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem{
    height:((userPic.height + nick.height)>
                (phoneModel.height+ messageid.height + supply.height)?
                 (userPic.height + nick.height):(phoneModel.height+ messageid.height + supply.height))
                + Theme.paddingMedium * 4
    contentHeight: height
    width: parent.width
    anchors.leftMargin: Theme.paddingSmall
    anchors.rightMargin: Theme.paddingSmall

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

    Label{
        id:date
        text: fmtTime(posttime) + "  " + floor
        font.pixelSize: Theme.fontSizeExtraSmall
        font.italic: true
        horizontalAlignment: Text.AlignRight
        anchors{
            right:parent.right
            top:userPic.top
            rightMargin: Theme.paddingMedium
        }
    }

    Image{
        id:userPic
        anchors {
            left: parent.left
            top:parent.top
            leftMargin: Theme.paddingSmall
            topMargin: Theme.paddingMedium
        }
        width:Screen.width/6 - Theme.paddingMedium
        height:width
        fillMode: Image.PreserveAspectFit;
        source: avatar
        Image{
            source: Qt.resolvedUrl("../gfx/noavatar.png");
            visible: parent.status == Image.Error
            anchors.fill: parent
            width: parent.width
            height: parent.height
        }

    }


     Label{
         id:nick
         text: nickname
         width: userPic.width
         font.pixelSize: Theme.fontSizeExtraSmall * 0.7
         
         horizontalAlignment: Text.AlignLeft
         truncationMode: TruncationMode.Elide
         maximumLineCount: 3
         wrapMode: Text.WordWrap
         anchors {
             top:userPic.bottom
             horizontalCenter: userPic.horizontalCenter
             topMargin: Theme.paddingSmall
         }
     }

    Label{
        id:phoneModel
        text:phone_model
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors {
            top:userPic.top
            left:userPic.right
            leftMargin: Theme.paddingMedium
        }
    }

    Label{
        id:messageid
        text:content
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.WordWrap
        color: Theme.highlightColor
        textFormat: Text.AutoText
        horizontalAlignment: Text.AlignLeft
        truncationMode: TruncationMode.Elide
        anchors {
            top:phoneModel.bottom
            left:userPic.right
            right:parent.right
            margins: Theme.paddingMedium
        }
    }

    Label{
        id:supply
        width: parent.width
        text: agree + " " + against
        wrapMode: Text.WordWrap
        opacity:0.9
        horizontalAlignment: Text.AlignRight
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors{
            right:parent.right
            top:messageid.bottom
            rightMargin: Theme.paddingMedium
        }

    }

    //model
    Separator {
        visible: (index>0?true:false)
        width:parent.width;
        color: Theme.highlightColor
    }
}
