#!/usr/bin/env python3

from bs4 import BeautifulSoup
import requests
import json

def parse_hot_comment(newsid):
    data = {
        'newsID': newsid,
        "pid" : 1,
        'type': 'hotcomment'
    }
    try:
        r = requests.post(
            'https://dyn.ithome.com/ithome/getajaxdata.aspx', data=data)
        result = r.text
        html = json.loads(result).get("html")
        if not html:
            return []
        html = html.replace("\u003c","<")
        html = html.replace("\u003e",">")
        return parse_html(html)
    except Exception as e:
        print(str(e))
        return None

def parse_comment_page(newsid):
    data = {
        'newsID': newsid,
        "page": 1,
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
        print(str(e))
        return None


def parse_html(html):
    info_list = []
    soup = BeautifulSoup(html, 'html.parser')
    comment_list = soup.find_all('li', class_='entry')
    for comment in comment_list:
        # 评论内容
        content = comment.find('p').text
        # 用户名
        name = comment.find('span', class_='nick').get_text()
        # 发帖时间与位置
        posandtime = comment.find("span", class_="posandtime").get_text()
        position = posandtime.split("\xa0")[0]
        posttime = posandtime.split("\xa0")[1]
        # 头像
        avatar = "https:" + comment.find("img", class_="headerimage")["src"]
        # 其他信息
        phone_model = comment.find("span", class_="mobile").get_text() if comment.find("span", class_="mobile") else ""
        floor = comment.find("strong", class_="p_floor").get_text()
        info_list.append(
            {'name': name,
             'content': content,
             'posttime': posttime,
             'position': position,
             'phone_model': phone_model,
             'avatar': avatar,
             'floor': floor
             })
        return info_list

def getHashId(newsid):
    url = "https://dyn.ithome.com/comment/" + newsid
    try:
        r = requests.get(url)
        html = r.text
        soup = BeautifulSoup(html, 'html.parser')
        hashid = soup.find("input", {"id":"hash"}).get('value')
        return hashid
    except Exception as e:
        print(str(e))
    return None

def getTotalComment(newsid):
    url = "https://dyn.ithome.com/api/comment/count?newsid=" + newsid
    try:
        r = requests.get(url)
        html = r.text
        # if(document.getElementById('commentcount')!=null)  document.getElementById('commentcount').innerHTML = '34';
        total = html.split("innerHTML")[1].replace("=","").replace("'","").replace(";","")
        return int(total)
    except Exception as e:
        print(str(e))
    return None

if __name__ == "__main__":
    print(parse_comment_page("376751"))