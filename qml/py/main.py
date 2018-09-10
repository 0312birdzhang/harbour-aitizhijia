# -*- coding: utf-8 -*-
from bs4 import BeautifulSoup
import requests
import json
import sys
import logging
import re


logger = logging.getLogger("aitizhijia")
formatter = logging.Formatter("%(asctime)s %(pathname)s %(filename)s %(funcName)s %(lineno)s \
%(levelname)s - %(message)s", "%Y-%m-%d %H:%M:%S")
console_handler = logging.StreamHandler(sys.stdout)
console_handler.formatter = formatter
logger.addHandler(console_handler)
logger.setLevel(logging.DEBUG)

def get_hot_comment(newsid):
    data = {
        'newsID': str(newsid),
        "pid" : 1,
        "hash": getHashId(newsid),
        'type': 'hotcomment'
    }
    try:
        r = requests.post(
            "https://dyn.ithome.com/ithome/getajaxdata.aspx",
             data=data
        )
        result = r.text
        if not result:
            return list()
        html = json.loads(result).get("html")
        if not html:
            return list()
        html = html.replace("\u003c","<")
        html = html.replace("\u003e",">")
        return parse_html(html)
    except Exception as e:
        logger.error(str(e))
        return list()

def get_comment_page(newsid,pagenum):
    data = {
        'newsID': str(newsid),
        "page": int(pagenum),
        "hash": getHashId(newsid),
        'type': 'commentpage',
        'order': False
    }
    try:
        r = requests.post(
            'https://dyn.ithome.com/ithome/getajaxdata.aspx', data=data)
        html = r.text
        return parse_html(html)
    except Exception as e:
        logger.error(str(e))
        return list()


def parse_html(html):
    info_list = []
    soup = BeautifulSoup(html, 'html.parser')
    comment_list = soup.find_all('li', class_='entry')
    for comment in comment_list:
        commentMap = parseComment(comment)
        comments_in_floor = comment.find_all('li', class_='gh')
        comm_infloor_list = []
        for j in comments_in_floor:
            comm_infloor_list.append(parseComment(j))
        commentMap["comm_infloor_list"] = comm_infloor_list
        info_list.append(commentMap)
    return info_list

def parseComment(comment):
    # 评论内容
    content = comment.find('p').text
    # 用户名
    nickname = comment.find('span', class_='nick').get_text()
    # 发帖时间与位置
    posandtime = comment.find("span", class_="posandtime").get_text()
    position = posandtime.split("\xa0")[0]
    posttime = posandtime.split("\xa0")[1]
    # 头像
    avatar = "https:" + comment.find("img", class_="headerimage")["src"]
    # 其他信息
    phone_model = comment.find("span", class_="mobile").get_text() if comment.find("span", class_="mobile") else ""
    floor = comment.find("strong", class_="p_floor").get_text()
    comm_reply = comment.find('span', class_='comm_reply').findChildren("a", recursive= False)
    if comm_reply and len(comm_reply) > 3:
        #支持
        agree = comm_reply[1].get_text()
        #反对
        against = comm_reply[2].get_text()
    else:
        agree = None
        against = None
    return {'nickname': nickname,
             'content': content,
             'posttime': posttime,
             'position': position,
             'phone_model': phone_model,
             'avatar': avatar,
             'floor': floor,
             "agree": agree,
             "against": against
             }


def getHashId(newsid):
    url = "https://dyn.ithome.com/comment/%s" % (newsid,)
    try:
        html = get(url)
#        logger.debug("hash html",html)
        soup = BeautifulSoup(html, "html.parser")
        # hashsoup = soup.find("input", attrs={"id":"hash"})
        # if hashsoup:
        #     hashid = hashsoup.get("value")
        #     return hashid
        pattern = re.compile(r"var ch11 = '(.*?)';$", re.MULTILINE | re.DOTALL)
        script = soup.find("script", text=pattern)
        if script:
            return pattern.search(script.text).group(1)
    except Exception as e:
        logger.error(str(e))
    return ""

def getCommentsNum(newsid):
    url = "https://dyn.ithome.com/api/comment/count?newsid=%s" % (str(newsid),)
    logger.debug(url)
    try:
        html = get(url)
        logger.debug(str(html))
        # if(document.getElementById('commentcount')!=null)  document.getElementById('commentcount').innerHTML = '34';
        total = html.split("innerHTML")[1].replace("=","").replace("'","").replace(";","")
        return int(total)
    except Exception as e:
        logger.error(str(e))
    return 0

def get(url):
    headers = {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36'}
    try:
        r = requests.get(url, headers=headers)
        return r.text
    except Exception as e:
        logger.error(str(e))
    return None


def post(url, data):
    headers = {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36'}
    try:
        r = requests.post(url, headers=headers, data = data)
        return r.text
    except Exception as e:
        logger.error(str(e))
    return None


if __name__ == "__main__":
    print(getCommentsNum("376751"))
