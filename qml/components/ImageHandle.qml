import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: imagePage

    property string localUrl: ""
    allowedOrientations:Orientation.All

    Flickable {
        id: imageFlickable
        anchors.fill: parent
        contentWidth: imageContainer.width; contentHeight: imageContainer.height
        clip: true
        onHeightChanged: if (imagePreview.status === Image.Ready) imagePreview.fitToScreen();

        Item {
            id: imageContainer
            width: Math.max(imagePreview.width * imagePreview.scale, imageFlickable.width)
            height: Math.max(imagePreview.height * imagePreview.scale, imageFlickable.height)

            Image {
                id: imagePreview

                property real prevScale

                function fitToScreen() {
                    scale = Math.min(imageFlickable.width / width, imageFlickable.height / height, 1)
                    pinchArea.minScale = scale
                    prevScale = scale
                }

                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                source: localUrl
                sourceSize.height: 1000;
                smooth: !imageFlickable.moving

                onStatusChanged: {
                    if (status == Image.Ready) {
                        fitToScreen()
                        loadedAnimation.start()
                    }
                }

                NumberAnimation {
                    id: loadedAnimation
                    target: imagePreview
                    property: "opacity"
                    duration: 250
                    from: 0; to: 1
                    easing.type: Easing.InOutQuad
                }

                onScaleChanged: {
                    if ((width * scale) > imageFlickable.width) {
                        var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) * scale / prevScale;
                        imageFlickable.contentX = xoff - imageFlickable.width / 2
                    }
                    if ((height * scale) > imageFlickable.height) {
                        var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) * scale / prevScale;
                        imageFlickable.contentY = yoff - imageFlickable.height / 2
                    }
                    prevScale = scale
                }
            }
        }

        PinchArea {
            id: pinchArea

            property real minScale: 1.0
            property real maxScale: 3.0

            anchors.fill: parent
            enabled: imagePreview.status === Image.Ready
            pinch.target: imagePreview
            pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
            pinch.maximumScale: maxScale * 1.5 // when over zoomed

            onPinchFinished: {
                imageFlickable.returnToBounds()
                if (imagePreview.scale < pinchArea.minScale) {
                    bounceBackAnimation.to = pinchArea.minScale
                    bounceBackAnimation.start()
                }
                else if (imagePreview.scale > pinchArea.maxScale) {
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }
            NumberAnimation {
                id: bounceBackAnimation
                target: imagePreview
                duration: 250
                property: "scale"
                from: imagePreview.scale
            }
        }
    }

    Loader {
        anchors.centerIn: parent
        sourceComponent: {
            switch (imagePreview.status) {
            case Image.Loading:
                return loadingIndicator
            case Image.Error:
                return failedLoading
            default:
                return undefined
            }
        }

        Component {
            id: loadingIndicator

            Item {
                height: childrenRect.height
                width: imagePage.width

                BusyIndicator {
                    id: imageLoadingIndicator
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: true
                }

                Text {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: imageLoadingIndicator.bottom; topMargin: Theme.paddingLarge
                    }
                    font.pixelSize: Theme.fontSizeSmall;
                    color: Theme.highlightColor;
                    text: qsTr("Loading image...%1").arg(Math.round(imagePreview.progress*100) + "%")
                }
            }
        }

        Component {
            id: failedLoading
            Text {
                font.pixelSize: Theme.fontSizeSmall;
                text: qsTr("Error loading image")
                color: Theme.highlightColor
            }
        }
    }

    VerticalScrollDecorator { flickable: imageFlickable }


    IconButton {
       enabled: imagePreview.status == Image.Ready
       visible: false
       anchors{
           right: imagePage.right;
           rightMargin: Theme.paddingLarge;
           bottom: imagePage.bottom;
           bottomMargin: Theme.paddingLarge;
       }
       width: Theme.iconSizeMedium+Theme.paddingMedium*2
       icon.source: "image://theme/icon-m-share"
       onClicked: {
           pageStack.push(Qt.resolvedUrl("ShareToPage.qml"),{
               "link": "",
               "linkTitle": ""
           })
       }
    }

    IconButton {
       enabled: imagePreview.status == Image.Ready
       anchors{
           right: imagePage.right;
           rightMargin: Theme.paddingLarge;
           bottom: imagePage.bottom;
           bottomMargin: Theme.paddingLarge;
       }
       width: Theme.iconSizeMedium+Theme.paddingMedium*2
       icon.source: "image://theme/icon-m-cloud-download"
       onClicked: {
           console.log(imagePreview.source);
           var filename = localUrl.split("/");
           py.downloadFile(localUrl, filename[filename.length-1]);

       }
    }
}
