.pragma library

Qt.include("api.js")

var app;
var signalcenter;

function sendWebRequest(url, callback, method, postdata) {
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
        switch(xmlhttp.readyState) {
        case xmlhttp.OPENED:signalcenter.loadStarted();break;
        case xmlhttp.HEADERS_RECEIVED:if (xmlhttp.status < 200 || xmlhttp.status >= 300)signalcenter.loadFailed(qsTr("connect error,code:")+xmlhttp.status+"  "+xmlhttp.statusText);break;
        case xmlhttp.DONE:if (xmlhttp.status >= 200 && xmlhttp.status < 300) {
                try {
                    callback(xmlhttp.responseText);
                    signalcenter.loadFinished();
                } catch(e) {
                    console.log(e.toString())
                    signalcenter.loadFailed(qsTr("loading erro..."));
                }
            } else {
                signalcenter.loadFailed("");
            }
            break;
        }
    }
    if(method==="GET") {
        xmlhttp.open("GET",url);
        xmlhttp.send();
    }
    if(method==="POST") {
        xmlhttp.open("POST",url);
        xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xmlhttp.setRequestHeader("Content-Length", postdata.length);
        xmlhttp.send(postdata);
    }
}


function request(url, callback){
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = (function(myxhr)
    {
        return function()
        {
            if(myxhr.readyState === 4) callback(myxhr);
        }
    })(xhr);
    xhr.open('GET', url, true);
    xhr.send('');
}

function doesFileExist(url, callback){
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.send('');
    xhr.onreadystatechange = (function(myxhr)
    {
        return function()
        {
            if(myxhr.readyState === 4) callback(myxhr);
        }
    })(xhr);
}

function parseJson(text) {
    var start = text.indexOf("{");
    if (start > 0)
        text = text.substring(start);
    return JSON.parse(text);
}

function sendJsonRequest(url, data, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== XMLHttpRequest.DONE)
            return;
        if (xhr.status >= 200 && xhr.status < 300) {
            try {
                callback(parseJson(xhr.responseText));
            } catch (error) {
                callback({ success: false, message: "服务器返回数据无法解析" });
            }
        } else {
            callback({ success: false, message: "连接失败（" + xhr.status + "）" });
        }
    };
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.send(JSON.stringify(data));
}

function appendNews(model, news, pinned) {
    if (!news || news.lapinid)
        return;
    model.append({
        "newsid": news.newsid,
        "postdate": news.postdate || "",
        "orderdate": news.orderdate || news.postdate || "",
        "image": news.image || "",
        "title": news.title || "",
        "commentcount": news.commentcount || 0,
        "hitcount": news.hitcount || 0,
        "topplat": pinned
    });
}

function loadNews(page, cursor, replace) {
    sendWebRequest(newslist(cursor), function(text) {
        var obj = parseJson(text);
        if (replace)
            page.listmodel.clear();
        if (replace && obj.toplist) {
            for (var i = 0; i < obj.toplist.length; ++i)
                appendNews(page.listmodel, obj.toplist[i], true);
        }
        var items = obj.newslist || [];
        for (var j = 0; j < items.length; ++j)
            appendNews(page.listmodel, items[j], false);
        page.hasMore = items.length > 0;
        page.nextCursor = page.hasMore ? getNextCursor(items[items.length - 1].orderdate) : "";
        page.loadingMore = false;
    }, "GET", "");
}

function loadNewsDetail(page, newsid) {
    sendWebRequest(newsdetail(newsid), function(text) {
        var data = parseJson(text);
        page.sourceName = data.newssource || "";
        page.authorName = data.newsauthor || "";
        page.editorName = data.z || "";
        page.articleModel = splitContent(data.detail || "", page);
        page.detailReady = true;
    }, "GET", "");
}

function loadComments(page, newsid, cursor, replace) {
    sendWebRequest(comments(newsid, cursor), function(text) {
        var data = parseJson(text);
        var list = data.content && data.content.clist ? data.content.clist : [];
        if (replace)
            page.commentModel.clear();
        for (var i = 0; i < list.length; ++i) {
            var wrapper = list[i];
            var item = wrapper.M || wrapper;
            var nested = wrapper.R || [];
            var replies = [];
            for (var j = 0; j < nested.length; ++j) {
                var reply = nested[j].M || nested[j];
                replies.push({
                    "commentId": reply.Ci || 0,
                    "nickname": reply.N || "匿名用户",
                    "replyTo": reply.pUserNick || "",
                    "avatar": avatarUrl(reply.Ui || 0),
                    "phone_model": reply.SF || "",
                    "posttime": reply.T || "",
                    "floor": reply.Ta || "",
                    "content": reply.C || "",
                    "agree": reply.S || 0,
                    "against": reply.A || 0
                });
            }
            page.commentModel.append({
                "commentId": item.Ci || 0,
                "nickname": item.N || "匿名用户",
                "avatar": avatarUrl(item.Ui || 0),
                "phone_model": item.SF || "",
                "posttime": item.T || "",
                "floor": item.Ta || "",
                "content": item.C || "",
                "agree": "赞 " + (item.S || 0),
                "against": "踩 " + (item.A || 0),
                "replies": replies
            });
            page.nextCursor = item.Ci || "";
        }
        page.hasMore = list.length > 0;
        page.loadingMore = false;
    }, "GET", "");
}

function login(username, password) {
    sendJsonRequest(passwordLoginUrl(), {
        userName: username,
        password: password
    }, function(result) {
        if (!result.success || !result.content) {
            signalcenter.loginFailed(result.message || "用户名或密码错误");
            app.showMessage(result.message || "登录失败");
            return;
        }
        if (!saveLoginResult(result.content, username)) {
            signalcenter.loginFailed("登录成功，但服务器未返回 userHash");
            app.showMessage("登录成功，但服务器未返回 userHash");
        }
    });
}

function saveLoginResult(content, fallbackName) {
    var user = content.userInfo || {};
    var hash = content.userHash || content.userhash || content.UserHash ||
               user.userHash || user.userhash || user.UserHash || "";
    if (!hash)
        return false;
    app.userhash = hash;
    app.username = user.userName || user.username || fallbackName || "";
    app.nickname = user.userNick || user.nickName || user.nickname || app.username;
    signalcenter.loginSuccessed();
    app.showMessage("登录成功：" + app.nickname);
    return true;
}

function requestCaptcha(page) {
    request(captchaUrl(), function(xhr) {
        if (xhr.status < 200 || xhr.status >= 300) {
            page.captchaFailed("验证码加载失败（" + xhr.status + "）");
            return;
        }
        try {
            var result = parseJson(xhr.responseText);
            if (!result.success) {
                page.captchaFailed(result.message || "验证码加载失败");
                return;
            }
            var content = result.content || {};
            if (!content.need) {
                page.captchaNotRequired();
                return;
            }
            page.showCaptcha(content.base64Image || "", content.words || "", content.info || "");
        } catch (error) {
            page.captchaFailed("验证码数据无法解析");
        }
    });
}

function sendSmsCode(page, countryCode, mobile, captchaToken, points) {
    sendJsonRequest(smsCodeUrl(), {
        mobile: countryCode + "-" + mobile,
        type: 1,
        captchaInfo: { info: captchaToken || "", points: points || [] }
    }, function(result) {
        if (result.success)
            page.smsCodeSent();
        else
            page.smsCodeFailed(result.message || "验证码发送失败");
    });
}

function loginByMobile(page, countryCode, mobile, code) {
    sendJsonRequest(mobileLoginUrl(), {
        mobile: countryCode + "-" + mobile,
        code: code
    }, function(result) {
        if (!result.success || !result.content) {
            page.mobileLoginFailed(result.message || "登录失败");
            return;
        }
        if (!saveLoginResult(result.content, mobile)) {
            page.mobileLoginFailed("登录成功，但服务器未返回 userHash");
            return;
        }
        page.mobileLoginSucceeded();
    });
}

function submitComment(newsid, content, parentCommentId, rootCommentId, successCallback) {
    if (!app.loggedIn) {
        app.showMessage("请先登录");
        return;
    }
    sendWebRequest(commentSubmitUrl(), function(text) {
        var message = text;
        try {
            var data = parseJson(text);
            message = data.msg || data.message || "评论已提交，等待审核";
        } catch (error) {
            if (!message || message.length > 80)
                message = "评论已提交，等待审核";
        }
        app.showMessage(message);
        signalcenter.commentSubmitted();
        if (successCallback)
            successCallback();
    }, "POST", commentPostData(app.userhash, app.nickname, newsid, content,
                                parentCommentId || 0, rootCommentId || 0));
}

var newsDetailPage;

function getRelated(newsid){
    var url = getRelatedUrl(newsid);
    console.log("related url:"+url)
    sendWebRequest(url,loadRelatedNewsList,"GET","");
}

function loadRelatedNewsList(oritxt){
    if(oritxt.indexOf("[") !== 0){
        oritxt = oritxt.substring(oritxt.indexOf("["))
    }
    var obj = JSON.parse(oritxt);
    if(obj){
        newsDetailPage.relatedmodel.clear();
        for(var i in obj){
                newsDetailPage.relatedmodel.append({
                   "newsid": obj[i].newsid,
                   "title": obj[i].newstitle,
                   "image": obj[i].img,
                   "postdate": obj[i].postdate,
                   "commentcount":""
               });
        }
    }
    else signalcenter.showMessage(obj.error);
}


function humanedate(utcDateStr){
    var thatday = new Date(utcDateStr)
    var _dateline = thatday.getTime();
    var now = new Date().getTime();
    var cha=(now-_dateline)/1000;
    if(cha<180){
        return "刚刚";
    }else if(cha<3600){
        return Math.floor(cha/60)+" 分钟前";
    }else if(cha<86400){
        return Math.floor(cha/3600)+" 小时前";
    }else if(cha<172800){
        return "昨天 "+Qt.formatDateTime(thatday,"hh")+':'+Qt.formatDateTime(thatday,"mm");
    }else if(cha<259200){
        return "前天 "+Qt.formatDateTime(thatday,"hh")+':'+Qt.formatDateTime(thatday,"mm");
    }else if(cha<345600){
        return Math.floor(cha/86400)+" 天前";
    }else{
        return thatday.getFullYear()+'-'+(thatday.getMonth()+1)+'-'+thatday.getDate();
    }
}

function splitContent(topic_content, parent) {
    var model = Qt.createQmlObject('import QtQuick 2.0; ListModel {}', parent);
    topic_content = app.formathtml(topic_content);
    topic_content = topic_content.replace(/<a[^<>]*href=\"([^<>"]*)\"\s+rel=\"nofollow\"><img\s+src=\"([^<>"]*)\".*?a>/g,"<img src=\"$2\" />"); //去掉图片上的超链接
    topic_content = topic_content.replace(/<img[^<>]*class=\"[^<>]*emoji-emoji-one[^<>]*\"[^<>]*alt=\"([^<>"]*)\"[^<>]*\/>/g,"$1"); // emoji 直接用图片alt中的
    var img_model = [];
    var iframe_model = [];
    var _replace_img_ = "__REPLACE_IMG__";
    var _replace_iframe_ = "__REPLACE_IFRAME__";
    var imgReg = /<img.*?src=\"(.*?)\"/gi;
    var iframeReg = /<iframe.*?src=\"(.*?)\"/gi;

    var srcReg = /src=[\'\"]?([^\'\"]*)[\'\"]?/i;
    var arr_img = topic_content.match(imgReg);
    var arr_iframe = topic_content.match(iframeReg);
    if(!arr_img && !arr_iframe){
        model.append({
            "type": "Text",
            "content": topic_content
        })
        return model;
    }
    for (var i = 0; arr_img && i < arr_img.length; i++) {
        var src = arr_img[i].match(srcReg);
        if(src){
            if(src[1]){
                img_model.push(src[1]);
            }
        }
    }

    for (var i = 0; arr_iframe && i < arr_iframe.length; i++) {
        var src = arr_iframe[i].match(srcReg);
        if(src){
            if(src[1]){
                iframe_model.push(src[1]);
            }
        }
    }

    topic_content = topic_content.replace(/<img.*?src=\"([^<>"]*)\".*?>/g,_replace_img_);

    var contents = topic_content.split(_replace_img_);
    for(var i = 0 ; i < contents.length; i++ ){
        // text 中处理iframe
        var text_content = contents[i];
        var text_contents = text_content.replace(/<iframe.*?src=\"([^<>"]*)\".*?iframe>/g,_replace_iframe_).split(_replace_iframe_);
        for(var j = 0; j < text_contents.length; j++){
            model.append({
                "type": "Text",
                "content": text_contents[j].replace("\\n","<br/>")
            })
            if(text_contents[j].indexOf("embed-responsive") > -1 || text_contents[j].indexOf("video-container") > -1){
                model.append({
                    "type": "Webview",
                    "content": iframe_model[j]
                })
            }else{

            }

        }

        if ( i < contents.length - 1){
            var src = img_model[i];
            if(src.lastIndexOf("gif") > 0){
                model.append({
                    "type": "AnimatedImage",
                    "content": src
                })
            }else{
                model.append({
                    "type": "Image",
                    "content": src
                })
            }

        }
    }
    return model;
}
