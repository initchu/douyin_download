#!/bin/bash
# 抖音视频下载器启动脚本

# 检查虚拟环境
if [[ -d "venv" ]]; then
    source venv/bin/activate
    python douyin_downloader.py
else
    python3 douyin_downloader.py
fi
