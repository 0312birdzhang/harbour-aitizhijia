/**
新闻列表 https://api.ithome.com/json/newslist/news?r=0
文章详情 https://api.ithome.com/xml/newscontent/350/412.xml
相关文章 https://api.ithome.com/json/tags/0350/350362.json
最热评论 https://dyn.ithome.com/json/hotcommentlist/350/87a8e5b144d81938.json
评论列表 https://dyn.ithome.com/json/commentlist/350/87a8e5b144d81938.json
评论详情 https://dyn.ithome.com/json/commentcontent/d739ee8f2ceb0a27.json
轮播新闻 https://api.ithome.com/xml/slide/slide.xml
圈子列表 https://apiquan.ithome.com/api/post?categoryid=0&type=0&orderTime=&visistCount&pageLength
圈子详情 https://apiquan.ithome.com/api/post/236076
圈子评论 https://apiquan.ithome.com/api/reply?postid=236076&replyidlessthan=3241294
**/

API_BASE = "https://api.ithome.com/"

function newslist(pageNum){
   return API_BASE + "json/newslist/news?r="+pageNum;
}

function newsdetail(newsid){
    return API_BASE + "xml/newscontent/"+ newsid.toString().slice(0,3) +"/"+newsid.toString().slice(3,6)+".xml"
}