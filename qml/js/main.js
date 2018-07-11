.pragma library
Qt.include("api.js")

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
                    console.log(e)
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

function getNewsList(pageNum){
    if(!pageNum)pageNum=0;
    var url = newslist(pageNum);
    sendWebRequest(url,loadNewsList,"GET","");
}
function loadNewsList(oritxt){
    var obj = JSON.parse(oritxt);
    if(obj){
        newsListPage.listmodel.clear();
        for(var i in obj.newslist){
            // drop ads
            if(obj.newslist[i].lapinid){
                continue;
            }
            newsListPage.listmodel.append(obj.newslist[i]);
        }
    }
    else signalcenter.showMessage(obj.error);
}


var newsDetailPage;

function getNewsDetail(newsid){
    var url = newsdetail(newsid);
    newsDetailPage.xmlModel.source = url;
}



function humanedate(thatday){
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

