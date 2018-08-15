import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem{
    id:showcomments
    height:((userPic.height + nick.height)>
                (phoneModel.height+ messageid.height)?
                 (userPic.height + nick.height):(phoneModel.height+ messageid.height))
                + Theme.paddingMedium * 4
    contentHeight: height
    width: parent.width
    anchors.leftMargin: Theme.paddingSmall
    anchors.rightMargin: Theme.paddingSmall


    Label{
        id:date
        text: posttime
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
        Image{
            source: avatar
            anchors.fill: parent
            width: parent.width
            height: parent.height
        }

    }


     Label{
         id:nick
         text: nickname
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

    //model
    Separator {
        visible: (index>0?true:false)
        width:parent.width;
        color: Theme.highlightColor
    }
}
