from bs4 import BeautifulSoup
import requests
import json

def get_hot_comment(newsid):
    data = {
        'newsID': int(newsid),
        "pid" : 1,
        'type': 'hotcomment'
    }
    try:
        r = requests.post(
            'https://dyn.ithome.com/ithome/getajaxdata.aspx', data=data)
        result = r.text
        print("1111")
        html = json.loads(result).get("html")
        print("1111")
        if not html:
            return []
        #html = html.replace("\u003c","<")
        #html = html.replace("\u003e",">")
        print("1111")
        return parse_html(html)
    except Exception as e:
        print(str(e))
        return list()

def get_comment_page(newsid):
    data = {
        'newsID': int(newsid),
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
        return list()


def parse_html(html):
    info_list = []
    soup = BeautifulSoup(html, 'html.parser')
    comment_list = soup.find_all('li', class_='entry')
    for comment in comment_list:
        content = comment.find('p').text
        nickname = comment.find('span', class_='nick').get_text()
        posandtime = comment.find("span", class_="posandtime").get_text()
        position = posandtime.split("\xa0")[0]
        posttime = posandtime.split("\xa0")[1]
        avatar = "https:%s" % ( comment.find("img", class_="headerimage")["src"],)
        phone_model = comment.find("span", class_="mobile").get_text() if comment.find("span", class_="mobile") else ""
        floor = comment.find("strong", class_="p_floor").get_text()
        print("33333")
        info_list.append(
            {'nickname': nickname,
             'content': content,
             'posttime': posttime,
             'position': position,
             'phone_model': phone_model,
             'avatar': avatar,
             'floor': floor
             })
        return info_list

def getHashId(newsid):
    url = "https://dyn.ithome.com/comment/%s" % (newsid,)
    try:
        r = requests.get(url)
        html = r.text
        soup = BeautifulSoup(html, 'html.parser')
        hashid = soup.find("input", {"id":"hash"}).get('value')
        return hashid
    except Exception as e:
        pass
    return 0

def getTotalComment(newsid):
    url = "https://dyn.ithome.com/api/comment/count?newsid=%s" % (newsid,)
    try:
        r = requests.get(url)
        html = r.text
        # if(document.getElementById('commentcount')!=null)  document.getElementById('commentcount').innerHTML = '34';
        total = html.split("innerHTML")[1].replace("=","").replace("'","").replace(";","")
        return int(total)
    except Exception as e:
        pass
    return 0
