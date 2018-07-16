import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView{
    id: toplistView
    width: parent.width
    clip: true
    model: listmodel
    delegate: NewsListComponents{}
    VerticalScrollDecorator {flickable: toplistView}

}