import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/main.js" as JS

Dialog {
    id: loginDialog
    //allowedOrientations: Orientation.All
    property bool phoneMode: loginType.currentIndex === 0
    property bool requestingCode: false
    property int countdown: 0
    property string captchaToken: ""
    property string captchaPrompt: ""
    property var captchaPoints: []
    canAccept: !phoneMode && usernameField.text.trim().length > 0 && passwordField.text.length > 0

    function beginSmsVerification() {
        if (requestingCode || countdown > 0)
            return
        if (phoneField.text.length < 11) {
            errorLabel.text = "请输入正确的手机号码"
            return
        }
        requestingCode = true
        errorLabel.text = ""
        JS.requestCaptcha(loginDialog)
    }

    function showCaptcha(image, words, token) {
        requestingCode = false
        captchaImage.source = image
        captchaPrompt = words
        captchaToken = token
        captchaPoints = []
        captchaOverlay.visible = true
    }

    function captchaNotRequired() {
        JS.sendSmsCode(loginDialog, countryField.text, phoneField.text, "", [])
    }

    function captchaFailed(message) {
        requestingCode = false
        errorLabel.text = message
    }

    function submitCaptchaPoint(px, py, dx, dy) {
        var next = captchaPoints.slice(0)
        next.push({ x: px, y: py, diffX: dx, diffY: dy })
        captchaPoints = next
        if (next.length === 2) {
            captchaOverlay.visible = false
            requestingCode = true
            JS.sendSmsCode(loginDialog, countryField.text, phoneField.text, captchaToken, next)
        }
    }

    function smsCodeSent() {
        requestingCode = false
        countdown = 60
        countdownTimer.start()
        errorLabel.text = "短信验证码已发送"
    }

    function smsCodeFailed(message) {
        requestingCode = false
        captchaPoints = []
        errorLabel.text = message
    }

    function mobileLoginFailed(message) { errorLabel.text = message }
    function mobileLoginSucceeded() { pageStack.pop() }

    onAccepted: {
        errorLabel.text = ""
        JS.login(usernameField.text.trim(), passwordField.text)
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            countdown--
            if (countdown <= 0) stop()
        }
    }

    SilicaFlickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: appwindow.pageContentWidth
        contentHeight: loginColumn.height

        Column {
            id: loginColumn
            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader { title: "登录"; acceptText: "登录" }

            ComboBox {
                id: loginType
                width: parent.width
                label: "登录方式"
                menu: ContextMenu {
                    MenuItem { text: "手机验证码登录" }
                    MenuItem { text: "密码登录" }
                }
            }

            Row {
                width: parent.width
                visible: loginDialog.phoneMode
                TextField {
                    id: countryField
                    width: parent.width * 0.25
                    text: "+86"
                    label: "区号"
                    inputMethodHints: Qt.ImhDialableCharactersOnly
                }
                TextField {
                    id: phoneField
                    width: parent.width * 0.75
                    label: "手机号"
                    placeholderText: label
                    inputMethodHints: Qt.ImhDigitsOnly
                }
            }

            Row {
                width: parent.width
                visible: loginDialog.phoneMode
                TextField {
                    id: smsField
                    width: parent.width * 0.55
                    label: "短信验证码"
                    placeholderText: "6 位验证码"
                    inputMethodHints: Qt.ImhDigitsOnly
                    maximumLength: 6
                }
                Button {
                    width: parent.width * 0.45 - Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    text: requestingCode ? "发送中…" : (countdown > 0 ? countdown + " 秒" : "获取验证码")
                    enabled: !requestingCode && countdown <= 0
                    onClicked: beginSmsVerification()
                }
            }

            TextField {
                id: usernameField
                width: parent.width
                visible: !loginDialog.phoneMode
                label: "手机号或邮箱"
                placeholderText: label
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            }

            PasswordField {
                id: passwordField
                width: parent.width
                visible: !loginDialog.phoneMode
                label: "密码"
                placeholderText: label
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: loginDialog.phoneMode
                text: "登录/注册"
                enabled: phoneField.text.length >= 11 && smsField.text.length === 6
                onClicked: {
                    errorLabel.text = ""
                    JS.loginByMobile(loginDialog, countryField.text, phoneField.text, smsField.text)
                }
            }

            Label {
                id: errorLabel
                width: parent.width - Theme.horizontalPageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: text === "短信验证码已发送" ? Theme.highlightColor : Theme.errorColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width - Theme.horizontalPageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: "继续即表示同意软媒用户协议和隐私政策。应用仅保存登录返回的 userHash 和昵称。"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }
        }
    }

    Item {
        id: captchaOverlay
        anchors.fill: parent
        visible: false
        z: 20

        Rectangle { anchors.fill: parent; color: "#b0000000" }

        Column {
            width: Math.min(parent.width, appwindow.pageContentWidth) - Theme.horizontalPageMargin * 2
            anchors.centerIn: parent
            spacing: Theme.paddingMedium

            Label {
                id: captchaWords
                width: parent.width
                text: "请依次点击文字【" + captchaPrompt + "】"
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item {
                width: parent.width
                height: captchaImage.sourceSize.width > 0
                        ? width * captchaImage.sourceSize.height / captchaImage.sourceSize.width : width * 0.6

                Image {
                    id: captchaImage
                    anchors.fill: parent
                    fillMode: Image.Stretch
                }

                Repeater {
                    model: captchaPoints
                    delegate: Rectangle {
                        width: Theme.itemSizeExtraSmall
                        height: width
                        radius: width / 2
                        color: Theme.highlightColor
                        x: modelData.diffX * parent.width / 100 - width / 2
                        y: modelData.diffY * parent.height / 100 - height / 2
                        Label { anchors.centerIn: parent; text: index + 1; color: Theme.primaryColor }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (captchaPoints.length >= 2 || captchaImage.sourceSize.width <= 0) return
                        submitCaptchaPoint(Math.floor(mouse.x * captchaImage.sourceSize.width / width),
                                           Math.floor(mouse.y * captchaImage.sourceSize.height / height),
                                           Math.round(mouse.x * 100 / width),
                                           Math.round(mouse.y * 100 / height))
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "换一张"
                onClicked: {
                    captchaOverlay.visible = false
                    requestingCode = true
                    JS.requestCaptcha(loginDialog)
                }
            }
        }
    }
}
