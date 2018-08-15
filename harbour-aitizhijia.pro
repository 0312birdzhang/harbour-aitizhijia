# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-aitizhijia

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-aitizhijia.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-aitizhijia.changes.in \
    rpm/harbour-aitizhijia.changes.run.in \
    rpm/harbour-aitizhijia.spec \
    rpm/harbour-aitizhijia.yaml \
    translations/*.ts \
    harbour-aitizhijia.desktop \
    qml/js/main.js \
    qml/js/api.js \
    qml/pages/NewsDetail.qml \
    qml/pages/SignalCenter.qml \
    qml/js/base64.js \
    qml/pages/DisclaimerDialog.qml \
    qml/components/SlidePage.qml \
    qml/components/CommentsPage.qml \
    qml/components/NewsListComponents.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-aitizhijia-de.ts
