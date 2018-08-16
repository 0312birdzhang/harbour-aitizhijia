import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page{
    id: commentsPage
    property string newsid
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
                pagenum = result;
            }
        }

    }

    SilicaFlickable{
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        Column{
            id: column
            spacing: Theme.paddingLarge
            SectionHeader{
                text: "热门评论"
                visible: hotModel.count > 0
                font.pixelSize: Theme.fontSizeMedium
            }
            Repeater{
                model: hotModel
                CommentsComponent{

                }
            }

            SectionHeader{
                text: "全部评论"
                visible: commentModel.count > 0
                font.pixelSize: Theme.fontSizeMedium
            }
            SilicaListView{
                id: view
                width: parent.width
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


        }
    }

    Component.onCompleted: {
        py.getHotComments(newsid);
        py.getAllComments(newsid,pagenum);
        py.getCommentsNum(newsid);
    }
}
