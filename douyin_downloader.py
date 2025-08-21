#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
抖音视频下载器
支持下载单个视频和合集视频
"""

import re
import sys
import requests
from pathlib import Path
import yt_dlp
from colorama import init, Fore, Style

# 配置
try:
    from config import COOKIE_SETTINGS
except Exception:
    COOKIE_SETTINGS = {
        'enabled': True,
        'file_path': 'cookies.txt',
        'file_type': 'header',
    }

# 初始化colorama
init(autoreset=True)

class DouyinDownloader:
    def __init__(self):
        self.download_path = Path("downloads")
        self.download_path.mkdir(exist_ok=True)
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        })

        # Cookie 配置
        self.cookie_enabled = bool(COOKIE_SETTINGS.get('enabled', True))
        self.cookie_file = Path(COOKIE_SETTINGS.get('file_path', 'cookies.txt'))
        self.cookie_type = COOKIE_SETTINGS.get('file_type', 'header').lower()
        self.cookie_header = None
        self.ytdlp_cookiefile = None

        self._load_cookies_from_file()
        
    def _load_cookies_from_file(self):
        if not self.cookie_enabled:
            return False
        if not self.cookie_file.exists():
            print(f"{Fore.YELLOW}未检测到Cookie文件: {self.cookie_file}{Style.RESET_ALL}")
            return False
        try:
            content = self.cookie_file.read_text(encoding='utf-8').strip()
            if not content:
                print(f"{Fore.YELLOW}Cookie文件为空: {self.cookie_file}{Style.RESET_ALL}")
                return False
            if self.cookie_type == 'netscape':
                # 直接交给 yt-dlp 的 cookiefile 处理
                self.ytdlp_cookiefile = str(self.cookie_file)
                print(f"{Fore.GREEN}✅ 已加载 Netscape Cookie 文件{Style.RESET_ALL}")
                return True
            else:
                # 作为整行 Cookie 头
                self.cookie_header = content
                # 同时注入到 requests 的 session cookies，便于解析短链
                for part in content.split(';'):
                    if '=' in part:
                        k, v = part.strip().split('=', 1)
                        self.session.cookies.set(k, v)
                print(f"{Fore.GREEN}✅ 已加载 Header Cookie 文件{Style.RESET_ALL}")
                return True
        except Exception as e:
            print(f"{Fore.YELLOW}⚠️  读取Cookie文件失败: {e}{Style.RESET_ALL}")
            return False

    def print_banner(self):
        banner = f"""
{Fore.CYAN}╔══════════════════════════════════════════════════════════════╗
║                    抖音视频下载器 v1.2                              ║
║                    支持单视频和合集下载                            ║
║                    Cookie: 文件手工配置                           ║
╚══════════════════════════════════════════════════════════════╝{Style.RESET_ALL}
        """
        print(banner)
    
    def get_user_input(self):
        print(f"{Fore.YELLOW}请选择下载模式：{Style.RESET_ALL}")
        print("1. 下载单个视频")
        print("2. 下载合集视频")
        print("3. 退出程序")
        while True:
            try:
                choice = input(f"{Fore.GREEN}请输入选择 (1-3): {Style.RESET_ALL}").strip()
                if choice in ['1', '2', '3']:
                    return choice
                else:
                    print(f"{Fore.RED}无效选择，请输入 1、2 或 3{Style.RESET_ALL}")
            except KeyboardInterrupt:
                print(f"\n{Fore.YELLOW}程序已退出{Style.RESET_ALL}")
                sys.exit(0)

    def get_download_url(self):
        print(f"\n{Fore.YELLOW}请输入抖音视频链接：{Style.RESET_ALL}")
        print("支持格式：")
        print("- 单个视频链接")
        print("- 合集链接")
        print("- 分享链接")
        while True:
            try:
                url = input(f"{Fore.GREEN}链接: {Style.RESET_ALL}").strip()
                if url:
                    return url
                else:
                    print(f"{Fore.RED}链接不能为空，请重新输入{Style.RESET_ALL}")
            except KeyboardInterrupt:
                print(f"\n{Fore.YELLOW}程序已退出{Style.RESET_ALL}")
                sys.exit(0)

    def extract_video_id(self, url):
        if "v.douyin.com" in url:
            try:
                response = self.session.get(url, allow_redirects=True, timeout=10)
                url = response.url
            except Exception as e:
                print(f"{Fore.RED}无法解析分享链接: {e}{Style.RESET_ALL}")
                return None
        patterns = [r'/video/(\d+)', r'video/(\d+)', r'/(\d+)/', r'item/(\d+)']
        for pattern in patterns:
            match = re.search(pattern, url)
            if match:
                return match.group(1)
        return None

    def _build_ytdlp_opts(self, video_id_or_prefix):
        outtmpl = str(self.download_path / f"{video_id_or_prefix}_%(title)s.%(ext)s")
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
        if self.cookie_header:
            headers['Cookie'] = self.cookie_header
        opts = {
            'format': 'best',
            'outtmpl': outtmpl,
            'quiet': False,
            'no_warnings': False,
            'extract_flat': False,
            'http_headers': headers,
        }
        if self.ytdlp_cookiefile:
            opts['cookiefile'] = self.ytdlp_cookiefile
        return opts

    def download_single_video(self, url):
        print(f"{Fore.BLUE}开始下载单个视频...{Style.RESET_ALL}")
        video_id = self.extract_video_id(url)
        if not video_id:
            print(f"{Fore.RED}无法提取视频ID{Style.RESET_ALL}")
            return False
        ydl_opts = self._build_ytdlp_opts(video_id)
        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                print(f"{Fore.YELLOW}正在获取视频信息...{Style.RESET_ALL}")
                info = ydl.extract_info(url, download=False)
                if info:
                    print(f"{Fore.GREEN}视频标题: {info.get('title', '未知')}{Style.RESET_ALL}")
                    print(f"{Fore.GREEN}视频时长: {info.get('duration', 0)}秒{Style.RESET_ALL}")
                    print(f"{Fore.YELLOW}开始下载视频...{Style.RESET_ALL}")
                    ydl.download([url])
                    print(f"{Fore.GREEN}视频下载完成！{Style.RESET_ALL}")
                    return True
                else:
                    print(f"{Fore.RED}无法获取视频信息{Style.RESET_ALL}")
                    return False
        except Exception as e:
            msg = str(e)
            if 'cookie' in msg.lower() or 'cookies' in msg.lower():
                print(f"{Fore.RED}下载失败：需要有效的Cookie{Style.RESET_ALL}")
                print(f"{Fore.YELLOW}请在 {self.cookie_file} 中配置Cookie，并在 config.py 中设置 COOKIE_SETTINGS{Style.RESET_ALL}")
            else:
                print(f"{Fore.RED}下载失败: {e}{Style.RESET_ALL}")
            return False

    def download_playlist(self, url):
        print(f"{Fore.BLUE}开始下载合集视频...{Style.RESET_ALL}")
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
        if self.cookie_header:
            headers['Cookie'] = self.cookie_header
        ydl_opts = {
            'format': 'best',
            'outtmpl': str(self.download_path / 'playlist_%(playlist_index)s_%(title)s.%(ext)s'),
            'quiet': False,
            'no_warnings': False,
            'extract_flat': False,
            'playlist_items': 'all',
            'http_headers': headers,
        }
        if self.ytdlp_cookiefile:
            ydl_opts['cookiefile'] = self.ytdlp_cookiefile
        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                print(f"{Fore.YELLOW}正在获取合集信息...{Style.RESET_ALL}")
                info = ydl.extract_info(url, download=False)
                if info and 'entries' in info:
                    total_videos = len(info['entries'])
                    print(f"{Fore.GREEN}合集名称: {info.get('title', '未知')}{Style.RESET_ALL}")
                    print(f"{Fore.GREEN}视频数量: {total_videos}{Style.RESET_ALL}")
                    confirm = input(f"{Fore.YELLOW}是否继续下载 {total_videos} 个视频？(y/n): {Style.RESET_ALL}").lower()
                    if confirm not in ['y', 'yes', '是']:
                        print(f"{Fore.YELLOW}已取消下载{Style.RESET_ALL}")
                        return False
                    print(f"{Fore.YELLOW}开始下载合集视频...{Style.RESET_ALL}")
                    ydl.download([url])
                    print(f"{Fore.GREEN}合集下载完成！{Style.RESET_ALL}")
                    return True
                else:
                    print(f"{Fore.RED}无法获取合集信息或合集为空{Style.RESET_ALL}")
                    return False
        except Exception as e:
            msg = str(e)
            if 'cookie' in msg.lower() or 'cookies' in msg.lower():
                print(f"{Fore.RED}下载失败：需要有效的Cookie{Style.RESET_ALL}")
                print(f"{Fore.YELLOW}请在 {self.cookie_file} 中配置Cookie，并在 config.py 中设置 COOKIE_SETTINGS{Style.RESET_ALL}")
            else:
                print(f"{Fore.RED}下载失败: {e}{Style.RESET_ALL}")
            return False

    def show_download_path(self):
        abs_path = self.download_path.absolute()
        print(f"\n{Fore.GREEN}下载路径: {abs_path}{Style.RESET_ALL}")
        print(f"{Fore.YELLOW}您可以在文件管理器中打开此文件夹查看下载的视频{Style.RESET_ALL}")

    def run(self):
        self.print_banner()
        if self.cookie_enabled:
            if not self.cookie_file.exists() or not self.cookie_file.read_text(encoding='utf-8').strip():
                print(f"{Fore.YELLOW}提示：当前启用了Cookie，但 {self.cookie_file} 不存在或为空{Style.RESET_ALL}")
                print(f"{Fore.YELLOW}请编辑该文件后重试（详见 COOKIE_GUIDE.md），或在 config.py 中关闭 COOKIE_SETTINGS.enabled{Style.RESET_ALL}\n")
        while True:
            choice = self.get_user_input()
            if choice == '3':
                print(f"{Fore.YELLOW}感谢使用抖音视频下载器！{Style.RESET_ALL}")
                break
            url = self.get_download_url()
            if choice == '1':
                success = self.download_single_video(url)
            elif choice == '2':
                success = self.download_playlist(url)
            if success:
                self.show_download_path()
            print(f"\n{Fore.YELLOW}是否继续下载其他视频？(y/n): {Style.RESET_ALL}")
            try:
                continue_choice = input().lower()
                if continue_choice not in ['y', 'yes', '是']:
                    print(f"{Fore.YELLOW}程序结束{Style.RESET_ALL}")
                    break
            except KeyboardInterrupt:
                print(f"\n{Fore.YELLOW}程序已退出{Style.RESET_ALL}")
                break

def main():
    try:
        downloader = DouyinDownloader()
        downloader.run()
    except KeyboardInterrupt:
        print(f"\n{Fore.YELLOW}程序已被用户中断{Style.RESET_ALL}")
    except Exception as e:
        print(f"{Fore.RED}程序运行出错: {e}{Style.RESET_ALL}")
        print(f"{Fore.YELLOW}请检查网络连接和链接格式{Style.RESET_ALL}")

if __name__ == "__main__":
    main()
