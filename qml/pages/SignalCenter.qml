import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject{
    signal loadStarted;
    signal loadFinished;
    signal loadFailed(string errorstring);
    signal loginSuccessed;
    signal loginFailed(string fail);

    signal getHotComment(var result);
    signal getCommentsNum(int result);
    signal getCommentPage(var result);
}
