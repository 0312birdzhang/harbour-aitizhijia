import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page{
    id: commentsPage
    property string newsid

    ListModel{
        id: hostModel
    }
    SilicaFlickable{
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        Column{
            id: column
            spacing: Theme.paddingLarge

            Repeater{
                model: hostModel
                CommentsComponent{

                }
            }

        }
    }

    Component.onCompleted: {
        py.getHotComments(newsid)
    }
}
