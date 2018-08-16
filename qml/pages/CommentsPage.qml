import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page{
    id: commentsPage
    property int newsid
    property int pagenum: 1

    ListModel{
        id: hotModel
    }

    ListModel{
        id: commentModel
    }

    Connections{
        target: signalCenter
        onGetHotComment:{
            if(result){
                for(var i = 0; i < result.length;i++){
                    hotModel.append(result[i]);
                }
            }
        }
        onGetCommentPage:{
            if(result){
                for(var i = 0; i < result.length;i++){
                    commentModel.append(result[i]);
                }
            }
        }
        onGetCommentsNum:{
            if(result > 0){
                pagenum = Math.ceil(result/30);
            }
        }

    }


    SilicaListView{
        id: view
        width: parent.width
        anchors.fill: parent
        clip: true
        header: Item{
            height: column.height
            width: parent.width
            anchors{
                left:parent.left
                right:parent.right
            }
            Column{
                id: column
                width: parent.width
                height: childrenRect.height
                spacing: Theme.paddingLarge
                SectionHeader{
                    text: "热门评论"
                    visible: hotModel.count > 0
                    font.pixelSize: Theme.fontSizeMedium
                }
                SilicaListView{
                    clip: true
                    model: hotModel
                    width: parent.width
                    delegate: CommentsComponent{

                    }
                }
                SectionHeader{
                    text: "全部评论"
                    visible: view.count > 0
                    font.pixelSize: Theme.fontSizeMedium
                }
            }
        }

        model: commentModel
        delegate: CommentsComponent{

        }

        onDraggingChanged: {
            if (!dragging && !loading) {
                if (atYEnd && pagenum > 1) {
                    py.getAllComments(newsid,pagenum);
                }
            }
        }

        ViewPlaceholder{
            enabled: view.count == 0
            text: "暂无评论"
            hintText: "稍后再来看吧"
        }
    }




    Component.onCompleted: {
        py.getHotComments(newsid);
        py.getAllComments(newsid,1);
        py.getCommentsNum(newsid);
    }
}
