Qt.include("tripledes.js")
Qt.include("mode-ecb-min.js")
Qt.include("pad-nopadding-min.js")
Qt.include("base64.js")

var key = "p#a@w^s(";

function getApiBase(){
    return "http://api.ithome.com/"
}

function getDynBase(){
    return "https://dyn.ithome.com/"
}

function newslist(cursor){
    return getApiBase() + "json/listpage/news/" + (cursor || "0");
}

function getRelatedUrl(newsid){
    return getApiBase() + "json/tags/0"+ newsid.toString().slice(0,3) +"/"+newsid.toString()+".json"
}

function loadMore(newsid){
    var prevNewsid = getLoadMoreId(newsid);
    console.log("crypted id:"+prevNewsid)
    return getApiBase() + "xml/newslist/news_"+ prevNewsid +".xml"
}

function newsdetail(newsid){
    return getApiBase() + "json/newscontent/" + newsid;
}

function getNextCursor(orderdate) {
    var value = orderdate || "";
    if (value.indexOf(".") >= 0)
        value = value.split(".")[0];
    value = value.replace(/-/g, "/").replace("T", " ");
    return encryptedHex(Date.parse(value).toString(), "w^s(1#a@");
}

function getCommentSn(newsid) {
    return encryptedHex(newsid.toString(), "(#i@x*l%");
}

function getUserHash(username, password) {
    return encryptedHex(username + "\f" + CryptoJS.MD5(password).toString(), "(#i@x*l%");
}

function userDataUrl(userhash) {
    return "https://my.ruanmei.com/api/User/Get?userHash=" + encodeURIComponent(userhash) +
            "&extra=4|ithome_symbian&appver=765&device=symbian";
}

function captchaUrl() {
    return "https://myapi.ruanmei.com/api/captcha/get?extra=ithome";
}

function smsCodeUrl() {
    return "https://myapi.ruanmei.com/api/verifycode/sendbysms?extra=ithome";
}

function mobileLoginUrl() {
    return "https://myapi.ruanmei.com/api/user/registerorloginbymobilecode?extra=ithome";
}

function passwordLoginUrl() {
    return "https://myapi.ruanmei.com/api/user/loginbypassword?extra=ithome";
}

function commentSubmitUrl() {
    return "https://cmt.ithome.com/api/comment/submit";
}

function commentPostData(userhash, nickname, newsid, content, parentCommentId, rootCommentId) {
    var fields = {
        "userhash": userhash,
        "newsid": newsid,
        "commentNick": nickname,
        "commentContent": content,
        "parentCommentID": parentCommentId || 0,
        "ppcid": rootCommentId || 0,
        "type": "comment",
        "ver": "765",
        "ServerDontDecode": true,
        "client": 8,
        "device": "Sailfish OS",
        "notify": false
    };
    var values = [];
    for (var keyName in fields)
        values.push(encodeURIComponent(keyName) + "=" + encodeURIComponent(fields[keyName]));
    return values.join("&");
}

function encryptedHex(value, secret) {
    while (value.length % 8 !== 0)
        value += "\u0000";
    var keyHex = CryptoJS.enc.Utf8.parse(secret);
    var encrypted = CryptoJS.DES.encrypt(value, keyHex, {
        iv: keyHex,
        mode: CryptoJS.mode.ECB,
        padding: CryptoJS.pad.NoPadding
    });
    return fmtBytes(str2UTF8(decode64(encrypted.toString())));
}

function comments(newsid, cursor) {
    var url = "https://cmt.ithome.com/api/comment/getnewscomment?sn=" + getCommentSn(newsid);
    return cursor ? url + "&cid=" + cursor : url;
}

function avatarUrl(uid) {
    var value = ("000000000" + uid).slice(-9);
    return "https://avatar.ithome.com/avatars/" + value.slice(0, 3) + "/" +
            value.slice(3, 5) + "/" + value.slice(5, 7) + "/" + value.slice(7) + "_60.jpg";
}

function getComments(newsid_des){
    return getDynBase() + "json/commentlist/350/"+ newsid_des +".json"
}

function getHotCommentlist(newsid_des){
    return getDynBase() + "json/hotcommentlist/350/" + newsid_des +".json"
}

function getCommentDetail(newsid_des){
    return getDynBase() + "json/commentcontent/"+ newsid_des + ".json"
}

function getSlide(){
    return getApiBase() + "xml/slide/slide.xml";
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


function getLoadMoreId(newsid) {
    
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
评论总数 https://dyn.ithome.com/api/comment/count?newsid=376761
*/
