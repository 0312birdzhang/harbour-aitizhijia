#!/usr/bin/env python3

from bs4 import BeautifulSoup
import requests

def parse_hot_comment(newsid):
    '''
    找到it之家新闻的热评
    return :info_list <list>
    '''
    info_list = []
    data = {
        'newsID': newsid,
        'type': 'hotcomment'
    }
    try:
        r = requests.post(
            'https://dyn.ithome.com/ithome/getajaxdata.aspx', data=data)
        r.raise_for_status()
        r.encoding = r.apparent_encoding
        soup = BeautifulSoup(r.text, 'lxml')
        comment_list = soup.find_all('li', class_='entry')
        for comment in comment_list:
            # 评论内容
            content = comment.find('p').text
            # 用户名
            name = comment.find('strong', class_='nick').get_text()
            # 其他信息
            info = comment.find('div', class_='info rmp').find_all('span')
            # 判断用户是否填写了手机尾巴
            # 对信息做出咸蛋的处理
            # 抓取到 手机厂商、型号、位置、时间
            # 方便最后做数据分析
            if len(info) > 1:
                phone_com = info[0].text.split(' ')[0]
                phone_model = info[0].text.split(' ')[1]
                loc = info[1].text.replace('IT之家', '').replace(
                    '网友', ' ').replace('\xa0', '').split(' ')[0]
                time = info[1].text.replace('IT之家', '').replace(
                    '网友', ' ').replace('\xa0', '').split(' ')[2]
            else:
                phone_com = '暂无'
                phone_model = '暂无'
                loc = info[0].text.replace('IT之家', '').replace(
                    '网友', ' ').replace('\xa0', '').split(' ')[0]
                time = info[0].text.replace('IT之家', '').replace(
                    '网友', ' ').replace('\xa0', '').split(' ')[2]

            info_list.append(
                {'name': name, 'content': content, 'phone_com': phone_com, 'phone_model': phone_model, 'loc': loc, 'time': time, })

        return info_list
    except:
        return None