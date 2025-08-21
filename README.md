# 抖音视频下载器

一个功能强大的抖音视频下载工具，支持下载单个视频和合集视频。

## 功能特点

- 🎥 支持单个视频下载
- 📚 支持合集视频批量下载
- 🔗 自动解析分享链接
- 🎨 彩色命令行界面
- 📁 自动创建下载目录
- 🏷️ 智能文件命名

## 系统要求

- Python 3.7 或更高版本
- 稳定的网络连接

### 支持的操作系统
- **Windows**: Windows 10/11 (推荐)
- **Linux**: Ubuntu, Debian, CentOS, RHEL, Fedora, Arch Linux, openSUSE
- **macOS**: 10.14+ (通过pip安装依赖)

## 安装步骤

### 1. 安装Python
如果您的系统还没有安装Python，请从 [Python官网](https://www.python.org/downloads/) 下载并安装Python 3.7+。

### 2. 下载程序
将整个项目文件夹下载到您的计算机上。

### 3. 安装依赖
在项目目录中打开命令提示符，运行：
```bash
pip install -r requirements.txt
```

## 使用方法

### Windows用户

#### 方法一：使用批处理文件（推荐）
1. 双击 `install.bat` 进行自动安装
2. 安装完成后双击 `run.bat` 启动程序

#### 方法二：命令行运行
1. 打开命令提示符
2. 切换到项目目录
3. 运行：`python douyin_downloader.py`

### Linux用户

#### 方法一：自动安装（推荐）
1. 给脚本添加执行权限：`chmod +x install.sh`
2. 运行安装脚本：`./install.sh`
3. 安装完成后使用：`./start.sh`

#### 方法二：手动安装
1. 给脚本添加执行权限：`chmod +x run.sh`
2. 运行环境检查：`./run.sh`
3. 或直接运行：`python3 douyin_downloader.py`

#### 方法三：使用包管理器
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip python3-requests python3-colorama
pip3 install yt-dlp --user

# CentOS/RHEL/Fedora
sudo yum install python3 python3-pip python3-requests python3-colorama
pip3 install yt-dlp --user

# Arch Linux
sudo pacman -S python python-pip python-requests python-colorama
pip install yt-dlp --user
```

## 使用说明

### 1. 选择下载模式
程序启动后会显示三个选项：
- **1** - 下载单个视频
- **2** - 下载合集视频  
- **3** - 退出程序

### 2. 配置Cookie（手工文件）
**重要**：抖音需要Cookie才能下载视频。请按以下步骤手工配置：
1. 打开 `config.py`，确认 `COOKIE_SETTINGS`：
   - `enabled`: 是否启用Cookie（默认 True）
   - `file_path`: Cookie文件路径（默认 `cookies.txt`）
   - `file_type`: `header` 或 `netscape`
2. 根据 `file_type` 在 `cookies.txt` 中粘贴对应格式的Cookie（详见 `COOKIE_GUIDE.md`）
3. 保存后重新运行程序即可

### 2. 输入视频链接
支持以下格式的链接：
- 单个视频链接：`https://www.douyin.com/video/1234567890`
- 合集链接：`https://www.douyin.com/collection/1234567890`
- 分享链接：`https://v.douyin.com/xxxxx/`

### 3. 等待下载完成
- 程序会自动显示下载进度
- 下载完成后会显示保存路径

## Cookie说明

### 为什么需要Cookie？
抖音为了保护内容，要求用户提供有效的Cookie才能下载视频。Cookie包含了您的登录状态和身份验证信息。

### 如何获取Cookie？
详细步骤请参考 `COOKIE_GUIDE.md` 文件；将获取到的 Cookie 粘贴到 `cookies.txt`。

### Cookie安全吗？
- Cookie文件保存在本地，不会上传到其他地方
- 包含您的登录信息，请勿分享给他人
- 建议定期更新Cookie以确保下载成功

### Cookie文件位置
- 默认文件：`cookies.txt`
- 可在 `config.py` 中修改 `COOKIE_SETTINGS.file_path`

## 下载目录

所有下载的视频都会保存在 `downloads` 文件夹中，文件命名格式：
- 单个视频：`视频ID_标题.扩展名`
- 合集视频：`playlist_序号_标题.扩展名`

## 常见问题

### Q: 下载失败怎么办？
A: 请检查：
- 网络连接是否正常
- 视频链接是否有效
- 视频是否已被删除或设为私密

### Q: 合集下载很慢？
A: 合集包含多个视频，下载时间取决于：
- 视频数量
- 网络速度
- 视频大小

### Q: 程序无法启动？
A: 请确保：
- Python已正确安装
- 依赖包已安装完成
- 在正确的目录中运行

## 注意事项

- 请遵守相关法律法规和平台规则
- 仅用于个人学习和合法用途
- 请尊重原创作者的版权
- 下载的视频仅供个人使用，不得用于商业用途

### Linux用户特别说明
- 首次运行前请给脚本添加执行权限：`chmod +x *.sh`
- 建议使用虚拟环境运行，避免依赖冲突
- 如遇到权限问题，请检查文件权限和用户权限
- 某些发行版可能需要手动安装系统依赖包

## 技术特点

- 使用 `yt-dlp` 作为下载引擎，支持多种格式
- 自动处理重定向和分享链接
- 智能提取视频ID和标题
- 彩色命令行界面，用户体验友好
- 异常处理完善，程序稳定可靠

## 许可证

本项目仅供学习和研究使用，请遵守相关法律法规。


