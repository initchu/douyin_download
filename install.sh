#!/bin/bash

# 抖音视频下载器 - Linux自动安装脚本
# 支持Ubuntu, CentOS, Debian, Arch Linux等主流发行版

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 检测Linux发行版
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$NAME
        VERSION=$VERSION_ID
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO=$(cat /etc/redhat-release)
    elif [[ -f /etc/debian_version ]]; then
        DISTRO="Debian $(cat /etc/debian_version)"
    else
        DISTRO="Unknown"
    fi
    
    print_message $CYAN "检测到系统: $DISTRO"
}

# 安装系统依赖
install_system_deps() {
    print_message $BLUE "安装系统依赖包..."
    
    case $DISTRO in
        *"Ubuntu"*|*"Debian"*)
            print_message $YELLOW "使用apt安装依赖..."
            sudo apt update
            sudo apt install -y python3 python3-pip python3-venv curl wget
            ;;
        *"CentOS"*|*"Red Hat"*|*"Fedora"*)
            print_message $YELLOW "使用yum/dnf安装依赖..."
            if command -v dnf &> /dev/null; then
                sudo dnf install -y python3 python3-pip python3-venv curl wget
            else
                sudo yum install -y python3 python3-pip python3-venv curl wget
            fi
            ;;
        *"Arch"*)
            print_message $YELLOW "使用pacman安装依赖..."
            sudo pacman -S --noconfirm python python-pip python-virtualenv curl wget
            ;;
        *"openSUSE"*)
            print_message $YELLOW "使用zypper安装依赖..."
            sudo zypper install -y python3 python3-pip python3-venv curl wget
            ;;
        *)
            print_message $YELLOW "未知发行版，请手动安装Python 3.7+和pip"
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        print_message $GREEN "✅ 系统依赖安装完成"
    else
        print_message $RED "❌ 系统依赖安装失败"
        exit 1
    fi
}

# 检查Python版本
check_python() {
    print_message $BLUE "检查Python环境..."
    
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
        PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
    else
        print_message $RED "❌ Python安装失败"
        exit 1
    fi
    
    print_message $GREEN "✅ Python版本: $PYTHON_VERSION"
    
    # 检查版本是否满足要求
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    
    if [[ $PYTHON_MAJOR -lt 3 ]] || [[ $PYTHON_MAJOR -eq 3 && $PYTHON_MINOR -lt 7 ]]; then
        print_message $RED "❌ Python版本过低，需要Python 3.7+"
        exit 1
    fi
}

# 检查pip
check_pip() {
    print_message $BLUE "检查pip包管理器..."
    
    if command -v pip3 &> /dev/null; then
        PIP_CMD="pip3"
    elif command -v pip &> /dev/null; then
        PIP_CMD="pip"
    else
        print_message $RED "❌ pip安装失败"
        exit 1
    fi
    
    print_message $GREEN "✅ pip版本: $($PIP_CMD --version)"
}

# 升级pip
upgrade_pip() {
    print_message $BLUE "升级pip包管理器..."
    
    if $PIP_CMD install --upgrade pip --user &> /dev/null; then
        print_message $GREEN "✅ pip升级完成"
    else
        print_message $YELLOW "⚠️  pip升级失败，继续安装依赖..."
    fi
}

# 创建虚拟环境
create_venv() {
    print_message $BLUE "创建Python虚拟环境..."
    
    if [[ -d "venv" ]]; then
        print_message $YELLOW "虚拟环境已存在，是否重新创建？(y/n): "
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf venv
        else
            print_message $GREEN "✅ 使用现有虚拟环境"
            return 0
        fi
    fi
    
    if $PYTHON_CMD -m venv venv; then
        print_message $GREEN "✅ 虚拟环境创建完成"
        
        # 激活虚拟环境
        source venv/bin/activate
        
        # 升级pip
        pip install --upgrade pip
        
        print_message $GREEN "✅ 虚拟环境已激活"
    else
        print_message $RED "❌ 虚拟环境创建失败"
        exit 1
    fi
}

# 安装Python依赖
install_python_deps() {
    print_message $BLUE "安装Python依赖包..."
    
    # 确保虚拟环境已激活
    if [[ -z "$VIRTUAL_ENV" ]]; then
        source venv/bin/activate
    fi
    
    print_message $YELLOW "正在安装依赖包，请稍候..."
    
    if pip install -r requirements.txt; then
        print_message $GREEN "✅ Python依赖安装完成"
    else
        print_message $RED "❌ Python依赖安装失败"
        print_message $YELLOW "尝试使用系统包管理器安装..."
        
        case $DISTRO in
            *"Ubuntu"*|*"Debian"*)
                sudo apt install -y python3-requests python3-colorama
                ;;
            *"CentOS"*|*"Red Hat"*|*"Fedora"*)
                if command -v dnf &> /dev/null; then
                    sudo dnf install -y python3-requests python3-colorama
                else
                    sudo yum install -y python3-requests python3-colorama
                fi
                ;;
        esac
        
        # 重新尝试安装最小依赖
        if pip install yt-dlp requests colorama;
        then
            print_message $GREEN "✅ 依赖安装完成"
        else
            print_message $RED "❌ 依赖安装最终失败"
            exit 1
        fi
    fi
}

# 创建下载目录
create_download_dir() {
    print_message $BLUE "创建下载目录..."
    
    if [[ ! -d "downloads" ]]; then
        mkdir -p downloads
        print_message $GREEN "✅ 下载目录创建完成"
    else
        print_message $GREEN "✅ 下载目录已存在"
    fi
}

# 设置权限
set_permissions() {
    print_message $BLUE "设置文件权限..."
    
    # 设置脚本执行权限
    chmod +x run.sh
    chmod +x install.sh
    chmod +x douyin_downloader.py
    
    # 设置下载目录权限
    chmod 755 downloads
    
    print_message $GREEN "✅ 权限设置完成"
}

# 创建启动脚本
create_launcher() {
    print_message $BLUE "创建启动脚本..."
    
    cat > start.sh << 'EOF'
#!/bin/bash
# 抖音视频下载器启动脚本

# 检查虚拟环境
if [[ -d "venv" ]]; then
    source venv/bin/activate
    python douyin_downloader.py
else
    python3 douyin_downloader.py
fi
EOF
    
    chmod +x start.sh
    print_message $GREEN "✅ 启动脚本创建完成"
}

# 显示安装完成信息
show_completion() {
    echo
    print_message $GREEN "========================================"
    print_message $GREEN "           安装完成！"
    print_message $GREEN "========================================"
    echo
    
    print_message $CYAN "现在您可以："
    echo "1. 运行启动脚本: ./start.sh"
    echo "2. 运行Linux脚本: ./run.sh"
    echo "3. 直接运行Python: python3 douyin_downloader.py"
    echo
    print_message $CYAN "下载的视频将保存在 downloads 文件夹中"
    echo
    
    if [[ -d "venv" ]]; then
        print_message $YELLOW "注意：程序使用虚拟环境，请使用 ./start.sh 启动"
    fi
}

# 主函数
main() {
    clear
    
    print_message $CYAN "╔══════════════════════════════════════════════════════════════╗"
    print_message $CYAN "║                抖音视频下载器 - Linux自动安装程序          ║"
    print_message $CYAN "║                    支持单视频和合集下载                    ║"
    print_message $CYAN "╚══════════════════════════════════════════════════════════════╝"
    echo
    
    # 检查是否为root用户
    if [[ $EUID -eq 0 ]]; then
        print_message $RED "❌ 请不要使用root用户运行此脚本"
        print_message $YELLOW "请使用普通用户运行，脚本会自动请求sudo权限"
        exit 1
    fi
    
    # 检测发行版
    detect_distro
    
    # 安装系统依赖
    install_system_deps
    
    # 检查Python环境
    check_python
    check_pip
    upgrade_pip
    
    # 创建虚拟环境
    create_venv
    
    # 安装Python依赖
    install_python_deps
    
    # 创建目录和设置权限
    create_download_dir
    set_permissions
    create_launcher
    
    # 显示完成信息
    show_completion
}

# 错误处理
trap 'echo -e "\n${RED}安装被中断${NC}"; exit 1' INT TERM

# 运行主函数
main "$@"
