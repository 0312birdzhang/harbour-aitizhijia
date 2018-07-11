import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject{
    signal loadStarted;
    signal loadFinished;
    signal loadFailed(string errorstring);
    signal loginSuccessed;
    signal loginFailed(string fail);

}
