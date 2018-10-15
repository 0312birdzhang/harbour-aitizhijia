.pragma library

Qt.include("api.js")

var app;
var signalcenter;

function sendWebRequest(url, callback, method, postdata) {
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
        switch(xmlhttp.readyState) {
        case xmlhttp.OPENED:signalcenter.loadStarted();break;
        case xmlhttp.HEADERS_RECEIVED:if (xmlhttp.status != 200)signalcenter.loadFailed(qsTr("connect error,code:")+xmlhttp.status+"  "+xmlhttp.statusText);break;
        case xmlhttp.DONE:if (xmlhttp.status == 200) {
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

var newsListPage;

function getNewsList(){
    var url = newslist();
    sendWebRequest(url,loadNewsList,"GET","");
}

function loadNewsList(oritxt){
    var obj = JSON.parse(oritxt);
    if(obj){
        for(var i in obj.newslist){
            var index = obj.newslist.length - i -1;
            if(obj.newslist[index].newsid > newsListPage.latestNewsid){
                // drop ads
                if(obj.newslist[index].lapinid){
                    continue;
                }
                var news = obj.newslist[index];
                newsListPage.listmodel.insert(0,{
                        "newsid":news.newsid,
                        "postdate":news.postdate,
                        "image":news.image,
                        "title":news.title,
                        "commentcount":news.commentcount,
                        "hitcount":news.hitcount,
                        "topplat":""

                        });
            }
        }
        if(!newsListPage.listmodel.get(0).topplat){
            for(var i in obj.toplist){
                // drop ads
                if(obj.toplist[i].lapinid){
                    continue;
                }
                var news = obj.toplist[i];
                newsListPage.listmodel.insert(0,{
                              "newsid":news.newsid,
                              "postdate":news.postdate,
                              "image":news.image,
                              "title":news.title,
                              "commentcount":news.commentcount,
                              "hitcount":news.hitcount,
                              "topplat":news.topplat

                          });
            }
        }
        newsListPage.latestNewsid = obj.newslist[0].newsid
    }
    else signalcenter.showMessage(obj.error);
}


function getMoreNews(newsid){
    return loadMore(newsid)
}


var newsDetailPage;

function getNewsDetail(newsid){
    var url = newsdetail(newsid);
    newsDetailPage.xmlModel.source = url;
}

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


function getSlideUrl(){
    return getSlide()
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
