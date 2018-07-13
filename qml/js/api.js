Qt.include("tripledes.js")
Qt.include("mode-ecb-min.js")
Qt.include("pad-nopadding-min.js")
Qt.include("base64.js")

function getApiBase(){
    return "https://api.ithome.com/"
}
function newslist(){
   return getApiBase() + "json/newslist/news?r=0";
}

function loadMore(newsid){
    var prevNewsid = getMiniNewsId(newsid);
    return getApiBase() + "xml/newslist/news_"+ prevNewsid +".xml"
}

function newsdetail(newsid){
    return getApiBase() + "xml/newscontent/"+ newsid.toString().slice(0,3) +"/"+newsid.toString().slice(3,6)+".xml"
}

function encryptByDES(message, key) {
    var keyHex = CryptoJS.enc.Utf8.parse(key);
    var encrypted = CryptoJS.DES.encrypt(message, keyHex, {
        iv: keyHex,
        mode: CryptoJS.mode.ECB,
        padding: CryptoJS.pad.NoPadding
    });
    return encrypted.toString();
}


function getMiniNewsId(newsid) {
    var key = "p#a@w^s(";
    var index = 0;
    var i = newsid.toString().length;
    if (i < 8) {
        i = 8 - i;
    } else {
        i %= 8;
        i = i != 0 ? 8 - i : 0;
    }
    while (index < i) {
        newsid = newsid.toString() + "\u0000";
        index++;
    }
    var encryptd = encryptByDES(newsid, key);
    return fmtBytes(str2UTF8(decode64(encryptd)));
}

function fmtBytes(arg5) {
    var v1 = "";
    for (var v0 = 0; v0 < arg5.length; ++v0) {
        var v2 = (arg5[v0] & 255).toString(16);
        if (v2.length == 1) {
            v1 = v1 + "0" + v2;
        } else {
            v1 = v1 + v2;
        }
    }
    return v1;
}

function str2UTF8(str){
    var bytes = new Array(); 
    var len,c;
    len = str.length;
    for(var i = 0; i < len; i++){
        c = str.charCodeAt(i);
        var s = parseInt(c).toString(2);
        bytes.push(c & 0xFF);
    }
    return bytes;
}

/*
新闻列表 https://api.ithome.com/xml/newslist/news.xml
请求更多 https://api.ithome.com/xml/newslist/news_05bffc036ce4305d.xml
文章详情 https://api.ithome.com/xml/newscontent/350/412.xml
相关文章 https://api.ithome.com/json/tags/0350/350362.json
最热评论 https://dyn.ithome.com/json/hotcommentlist/350/87a8e5b144d81938.json
评论列表 https://dyn.ithome.com/json/commentlist/350/87a8e5b144d81938.json
评论详情 https://dyn.ithome.com/json/commentcontent/d739ee8f2ceb0a27.json
轮播新闻 https://api.ithome.com/xml/slide/slide.xml
圈子列表 https://apiquan.ithome.com/api/post?categoryid=0&type=0&orderTime=&visistCount&pageLength
圈子详情 https://apiquan.ithome.com/api/post/236076
圈子评论 https://apiquan.ithome.com/api/reply?postid=236076&replyidlessthan=3241294
*/
