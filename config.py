# -*- coding: utf-8 -*-
"""
抖音下载器配置文件
用户可以在这里修改默认设置
"""

# 下载设置
DOWNLOAD_SETTINGS = {
    # 下载质量 (best, worst, bestvideo+bestaudio)
    'format': 'best',
    
    # 下载路径 (相对于程序目录)
    'download_path': 'downloads',
    
    # 是否显示下载进度
    'show_progress': True,
    
    # 是否自动重命名文件
    'auto_rename': True,
    
    # 下载超时时间(秒)
    'timeout': 30,
    
    # 重试次数
    'retries': 3,
    
    # 是否跳过已存在的文件
    'skip_existing': True,
}

# 网络设置
NETWORK_SETTINGS = {
    # 请求超时时间
    'request_timeout': 10,
    
    # 最大重定向次数
    'max_redirects': 5,
    
    # 用户代理
    'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    
    # 语言
    'accept_language': 'zh-CN,zh;q=0.9,en;q=0.8'
}

# 界面设置
UI_SETTINGS = {
    # 是否启用彩色输出
    'enable_colors': True,
    
    # 是否显示详细日志
    'verbose_logging': False,
    
    # 语言设置 (zh-CN, en-US)
    'language': 'zh-CN'
}

# 文件命名模板
FILENAME_TEMPLATES = {
    # 单个视频命名模板
    'single_video': '{video_id}_{title}.{ext}',
    
    # 合集视频命名模板
    'playlist_video': 'playlist_{playlist_index}_{title}.{ext}',
    
    # 合集文件夹命名模板
    'playlist_folder': '{playlist_title}'
}

# Cookie 设置（手工文件配置）
# file_type 可选：
# - 'header'   表示文件内容为一整行 Cookie 头（ttwid=...; msToken=...; ...）
# - 'netscape' 表示文件为 Netscape/Mozilla Cookies.txt 格式（适合从浏览器导出的cookies）
COOKIE_SETTINGS = {
    'enabled': True,
    'file_path': 'cookies.txt',
    'file_type': 'netscape',
}
