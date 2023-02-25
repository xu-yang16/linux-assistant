#!/bin/bash
sudo apt install -y xterm zenity curl
codename=$(lsb_release -sc)
echo "检测到您的Ubuntu系统版本为：$codename"
username=$(whoami)

resize -s 45 90
SELECT=$(whiptail --title "Ubuntu助手" --checklist \
"选择要安装的软件或电脑配置（可多选，空格键选择，Tab键跳转)" 45 90 30 \
"换源&Clean" "  删除不需要的软件" OFF \
"Julia" "安装Julia" OFF \
"kazam" "录屏软件" OFF \
"Vim配置" "  Vim自定义配置" OFF \
"键盘配置" "    对调Esc和Caps" OFF \
"Git" "版本管理软件" OFF \
"Fish" "更智能的终端" OFF \
"搜狗拼音输入法" "       Linux版搜狗拼音输入法" OFF \
"重命名folder" "documents, downloads etc." OFF \
"VSCode" "代码编辑器，功能强大、易用" OFF \
"Miniconda3" "Python虚拟环境管理器" OFF \
"Isaacgym" "Isaacgym" OFF \
"sysmonitor&stacer&backintime" "安装监控软件sysmonitor, stacer and backintime" OFF \
"代理软件" "    Clash for Windows" OFF \
"Ubuntu美化" "  Ubuntu美化" OFF \
"Google Chrome" "谷歌浏览器" OFF \
"Zotero" "文献管理软件" OFF \
"ROS" "安装ROS" OFF \
"ROS2" "安装ROS2" OFF \
"NVIDIA显卡驱动" "    安装此项后安装CUDA时就不需选择Driver了" OFF \
"VirtualBox" "虚拟机软件" OFF \
3>&1 1>&2 2>&3
)


Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White


Flag_Doc=0        # 0 stands for no need of a doc, 1 otherwise.

# to determine os language
if [ -d "${HOME}/Desktop" ]
then
    FileLocation="${HOME}/Desktop/Ubuntu助手附加说明.txt"
else
    FileLocation="${HOME}/桌面/Ubuntu助手附加说明.txt"
fi


touch_check() {
    cd ~/Desktop || cd ~/桌面
    if [ ! -f "Ubuntu助手附加说明.txt" ];then
        touch ~/Desktop/Ubuntu助手附加说明.txt || touch ~/桌面/Ubuntu助手附加说明.txt
    fi
}

echo_out() {
    echo "$1" >> ~/Desktop/Ubuntu助手附加说明.txt || echo "$1" >> ~/桌面/Ubuntu助手附加说明.txt
}

function success {
    # if you want to use colored font display, must add -e parameter.
    echo -e "${BGreen}安装成功！${Color_Off}"
}

function config_success {
	# if you want to use colored font display, must add -e parameter.
	echo -e "${BGreen}配置成功！${Color_Off}"
}

selects() {
    echo $SELECT | grep "$1" && "$2"
}

###############安装##############

function config_clean {
    echo -e "${BGreen}将要换清华源${Color_Off}" && sleep 1s
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
    sudo sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
    sudo apt update
    echo -e "${BGreen}将要卸载libreoffice和thunderbird${Color_Off}" && sleep 1s
    sudo apt purge libreoffice* thunderbird*
    sudo apt install -y vim gedit net-tools neovim cmake g++ flameshot neofetch python3-pip
    # 更换文件夹名称
    cp ./dotfile/user-dirs.dirs ~/.config/
    # 截图配置
    mkdir -p ~/.config/flameshot
    cp ./dotfile/flameshot.ini ~/.config/flameshot/
    # lolcate配置
    sudo cp ./dotfile/lolcate/lolcate /usr/bin/
    /usr/bin/lolcate --create
    sed -i "s/caslx/${username}/g" ./dotfile/lolcate/default/config.toml
    cp -rf ./dotfile/lolcate ~/.config
    
    # pip换清华源
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    config_success
}

function config_keyboard {
    echo -e "${BGreen}将要配置键盘${Color_Off}" && sleep 1s
    # esc与cap互换
    sudo cp /usr/share/X11/xkb/symbols/pc /usr/share/X11/xkb/symbols/pc.bak
    sudo cp ./dotfile/pc /usr/share/X11/xkb/symbols/pc
    # 键盘快捷键
    gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>comma']"
    gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q', '<Alt>F4']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>t']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>b']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
    # 截图
    sudo apt -y install flameshot
    # 火焰截图快捷键
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Primary><Shift>a'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'flameshot gui'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name '火焰截图'
    config_success
}

function config_git {
    echo -e "${BGreen}将要安装git${Color_Off}" && sleep 1s
    sudo apt -y install git
    git config --global user.email "yangx21@mails.tsinghua.edu.cn"
    git config --global user.name "yx"
    ssh-keygen -f ~/.ssh/gitlab-rsa -N ""
    ssh-keygen -f ~/.ssh/github-rsa -N ""
    success
}

function config_fish {
    echo -e "${BGreen}将要安装fish${Color_Off}" && sleep 1s
    sudo apt -y install fish
    # 设置默认shell
    chsh -s /usr/bin/fish
    curl -L https://get.oh-my.fish | fish
    omf install clearance
    omf install https://github.com/xu-yang16/colcon-abbr.fish
    config_success
}

function config_sogou {
    echo -e "${BGreen}将要安装搜狗输入法${Color_Off}" && sleep 1s
    sudo apt install -y fcitx
    # 设置fcitx开机自启动
    sudo cp /usr/share/applications/fcitx.desktop /etc/xdg/autostart/
    sudo apt purge -y ibus
    sudo apt install -y libqt5qml5 libqt5quick5 libqt5quickwidgets5 qml-module-qtquick2 libgsettings-qt1
    # 安装sogou
    cd 
    wget -O sogoupinyin.deb https://cloud.tsinghua.edu.cn/f/acc1fd55cefc49cb9f08/?dl=1
    sudo dpkg -i sogoupinyin.deb
    rm sogoupinyin.deb
    # sogou配置
    mkdir -p ~/.config/sogoupinyin
    cp ./dotfile/sogou_env.ini ~/.config/sogoupinyin/env.ini
    touch_check && echo_out "【搜狗拼音输入法】" && echo_out "请打开地区和语言设置->管理已安装语言->系统输入法框架，更改为fcitx，然后重启。重启后在输入法中添加搜狗，具体操作请参考：https://pinyin.sogou.com/linux/guide。只参考系统设置部分就可以，安装部分已经完成。"
    config_success
}

function config_folder {
    echo -e "${BGreen}将要重命名folder${Color_Off}" && sleep 1s
    cp ./dotfile/user-dirs.dirs ~/.config/
    mv ~/下载 ~/downloads
    mv ~/文档 ~/documents
    mv ~/桌面 ~/desktop
    mv ~/音乐 ~/music
    mv ~/视频 ~/videos
    mv ~/图片 ~/pictures
    mv ~/公共 ~/public
    mv ~/模板 ~/templates
    config_success
}

function config_vscode {
    echo -e "${BGreen}将要安装VSCode${Color_Off}" && sleep 1s
    cd
    wget -O code.deb --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo dpkg -i code.deb
    rm code.deb
    success
}

function config_miniconda {
    echo -e "${UBlue}将要安装miniconda${Color_Off}" && sleep 1s
    cd
    wget -O miniconda.sh https://mirror.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh
    chmod +x miniconda.sh
    ./miniconda.sh
    rm miniconda.sh
    # 配置环境变量
    conda init bash
    conda init fish
    conda config --set auto_activate_base false
    # 换源
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
    echo_out "conda换为清华源"
    success
}

function config_isaacgym {
	echo -e "${BGreen}将要安装isaac gym${Color_Off}" && sleep 1s
    cd ~ && wget -O IsaacGym_Preview_4_Package.tar.gz https://cloud.tsinghua.edu.cn/f/36660a82fd344874be10/?dl=1
    tar -xzvf IsaacGym_Preview_4_Package.tar.gz
    conda create -n legged -y python=3.8
    conda activate legged
	cd IsaacGym_Preview_4_Package/python && pip install -e .
	cd examples && python 1080_balls_of_solitude.py
    echo_out "isaac gym 安装完成"
}

function config_julia {
    echo -e "${BGreen}将要安装julia${Color_Off}" && sleep 1s
    cd
    wget -O julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.3-linux-x86_64.tar.gz
    mkdir -p ~/softwares/julia
    tar -zxvf julia.tar.gz -C ~/softwares/julia --strip-components 1
    # 配置环境变量
    echo "# install julia" >> ~/.bashrc
    echo "export PATH=\$PATH:~/softwares/julia/bin" >> ~/.bashrc
    echo "export JULIA_DEPOT_PATH=~/softwares/julia_package" >> ~/.bashrc
    echo "# julia" >> ~/.config/fish/config.fish
    echo "set -x fish_user_paths ~/softwares/julia/bin \$fish_user_paths" >> ~/.config/fish/config.fish
    echo "set -x JULIA_DEPOT_PATH ~/softwares/julia_package" >> ~/.config/fish/config.fish
    rm ~/julia.tar.gz
    success
}

function config_kazam {
    echo -e "${BGreen}将要安装kazam${Color_Off}" && sleep 1s
    sudo apt -y install kazam
    sudo cp ./kazam/*.py /usr/lib/python3/dist-packages/kazam/backend
    success
}

function config_vim {
    echo -e "${BGreen}将要配置vim${Color_Off}" && sleep 1s
    cd
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    config_success
}

function config_proxy {
    echo -e "${UBlue}将要配置clash_for_windows${Color_Off}" && sleep 1s
    cd
    mkdir -p ~/softwares/clash
    wget -O clash.tar.gz https://cloud.tsinghua.edu.cn/f/6cf786da854440faba41/?dl=1
    tar -zxvf clash.tar.gz -C ~/softwares/clash --strip-components 1
    # 设置开机自启动
    mkdir -p ~/.config/autostart
    echo -e "[Desktop Entry]\\nName=clash\\nExec=/home/$username/softwares/clash/cfw\\nType=Application\\nTerminal=false\\nHidden=false" > ~/.config/autostart/clash.desktop
    rm ~/clash.tar.gz
    # 读取配置文件，订阅
    cd
    wget -O 加密.zip https://cloud.tsinghua.edu.cn/f/7629099abd364f6492c8/?dl=1
    unzip -o 加密.zip   # passwd is needed
    mkdir -p ~/.config/clash/profiles
    cp 加密/config.yaml 加密/cfw-settings.yml ~/.config/clash/
    cp 加密/list.yaml 加密/1669302728798.yml ~/.config/clash/profiles/
    rm 加密.zip && rm -rf ~/加密/
    # automatic network setting
    gsettings set org.gnome.system.proxy mode 'manual'
    gsettings set org.gnome.system.proxy.http host '127.0.0.1'
    gsettings set org.gnome.system.proxy.http port 7890
    gsettings set org.gnome.system.proxy.https host '127.0.0.1'
    gsettings set org.gnome.system.proxy.https port 7890
    gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
    gsettings set org.gnome.system.proxy.socks port 7891
    echo_out "【clash_for_windows设置】更新订阅链接"
    config_success
}

function config_sysmonitor {
    echo -e "${BGreen}将要安装sysmonitor, stacer, backintime...${Color_Off}"
    # 安装sysmonitor
    sudo add-apt-repository ppa:fossfreedom/indicator-sysmonitor
    sudo apt update
    sudo apt -y install indicator-sysmonitor stacer backintime-qt4
    # copy displayIP.sh
    mkdir ~/softwares
    cp ./dotfile/displayIP.sh ~/softwares/
    chmod +x ~/softwares/displayIP.sh 
    cp .dotfile/indicator-sysmonitor.json ~/
    # stacer开机自启动
    echo -e "[Desktop Entry]\\nName=Stacer\\nComment=Linux System Optimizer and Monitoring\\nExec=env QT_SCALE_FACTOR=0.75 QT_AUTO_SCREEN_SCALE_FACTOR=1 stacer --hide\\nType=Application\\nTerminal=false\\nHidden=false" > ~/.config/autostart/stacer.desktop
    echo -e "${BGreen}添加/home/${username}/softwares/displayIP.sh到indicator-sysmonitor${Color_Off}"
    success
}

#################################################################################################################

function config_beautify {
    echo -e "${BGreen}将要进行Ubuntu美化${Color_Off}" && sleep 1s
    sudo apt -y install gnome-tweaks plank
    # plank开机自启动
    echo -e "[Desktop Entry]\\nName=plank\\nComment=plank\\nExec=plank\\nType=Application\\nTerminal=false\\nHidden=false" > ~/.config/autostart/plank.desktop
    # 主题配置
    mv ./dotfile/themes ~/.themes
    cd 
    wget -O backgrounds.zip https://cloud.tsinghua.edu.cn/f/19513c92c98147589e25/?dl=1
    wget -O gnome-shell.zip https://cloud.tsinghua.edu.cn/f/b37b794c5b624a8b8509/?dl=1
    unzip -o backgrounds.zip
    unzip -o gnome-shell.zip
    mv ~/backgrounds ~/.local/share/
    mv ~/gnome-shell/* ~/.local/share/
    rm backgrounds.zip gnome-shell.zip
    rm -rf gnome-shell
    # workspace 快捷键设置
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Primary>Left']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Primary>Right']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Primary><Shift>Left']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Primary><Shift>Right']"
    # gnome设置
    gsettings set org.gnome.desktop.interface clock-show-seconds 'false'
    gsettings set org.gnome.desktop.interface clock-show-weekday 'true'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
    gsettings set org.gnome.desktop.interface enable-hot-corners 'true'
    gsettings set org.gnome.desktop.interface font-hinting 'slight'
    # 
    
    config_success
}

function config_chrome {
    echo -e "${BYellow}将要安装Google Chrome${Color_Off}" && sleep 1s
    cd
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install ./google-chrome-stable_current_amd64.deb
    rm google-chrome*.deb
    success
}

function config_zotero {
    echo -e "${BGreen}将要安装zotero${Color_Off}" && sleep 1s
    cd 
    mkdir -p ~/softwares/zotero && cd ~/softwares
    wget -O zotero.tar.bz2 --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0" https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=6.0.18
    wget https://github.com/jlegewie/zotfile/releases/download/v5.1.2/zotfile-5.1.2-fx.xpi
    tar -jxvf zotero.tar.bz2 -C ~/softwares/zotero --strip-components 1
    # update the .desktop file for that location
    bash ~/softwares/zotero/set_launcher_icon
    # symlink
    ln -s ~/softwares/zotero/zotero.desktop ~/.local/share/applications/zotero.desktop
    echo_out "【zotero设置】"
    echo_out "zotero首选项-同步-设置, 首先登录，勾选自动同步、同步全文内容、同步文献库中的附件，使用WebDAV；url为https://app.koofr.net/dav/OneDrive for Business/zotero，用户名2306669517@qq.com；进入zotero首选项-高级-文件和文件夹，根目录为/home/$username/SeaDrive/我的资料库/zotero/papers，数据存储位置为自定义：/home/$username/softwares/zotero_data"
    success
}

function config_ROS {
    echo -e "${BGreen}将要安装ROS${Color_Off}"
    ROS_DISTRO=noetic
    if test "$codename" = "focal"; then
        ROS_DISTRO=noetic
        sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
        sudo apt install curl # if you haven't already installed curl
        curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
        sudo apt update
        sudo apt install ros-$ROS_DISTRO-desktop-full
        sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
        sudo apt install python3-rosdep
        sudo rosdep init
        rosdep update
        # install catkin
        sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" \
        > /etc/apt/sources.list.d/ros-latest.list'
        wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
        sudo apt-get update
        sudo apt-get install python3-catkin-tools

    else
        echo -e "${BRed}仅支持ubuntu20，安装失败...${Color_Off}"
        return -1
    fi
}

function config_ROS2 {
    echo -e "${BGreen}将要安装ROS2${Color_Off}"
    ROS_DISTRO=humble
    if test "$codename" = "focal"; then
        ROS_DISTRO=foxy
    else if test "$codename" = "jammy"; then
        ROS_DISTRO=humble
    else
        echo -e "${BRed}仅支持ubuntu20和22，安装失败...${Color_Off}"
        return -1
    fi
    # ensure that the Ubuntu Universe repository is enabled.
    sudo apt -y install python3-argcomplete
    sudo apt -y install software-properties-common
    sudo add-apt-repository universe
    sudo apt update && sudo apt install curl
    # add the ROS 2 GPG key with apt
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    # add the repository to the sources list
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
    sudo apt -y install ros-$ROS_DISTRO-desktop 
    # 写入bashrc环境变量
    echo "#ROS2 $ROS_DISTRO" >> ~/.bashrc
    echo source /opt/ros/$ROS_DISTRO/setup.bash >> ~/.bashrc
    # 写入fish config环境变量
    echo "#ROS2 $ROS_DISTRO" >> ~/.config/fish/config.fish
    echo bass source /opt/ros/$ROS_DISTRO/setup.bash >> ~/.config/fish/config.fish
    # bass in fish
    omf install bass
    config_success
}

function config_nvidia {
    echo -e "${BGreen}将要安装NVIDIA显卡驱动${Color_Off}"
    sudo add-apt-repository ppa:graphics-drivers/ppa
    sudo apt update
    sudo ubuntu-drivers autoinstall   # for recommended
    # sudo  apt install nvidia-driver-xxx  # for self-assignment
    success
    touch_check
    echo_out "【NVIDIA显卡驱动】"
    echo_out "请不要再更新内核，有可能导致显卡驱动失效。如果启动过程有任何问题，或者没有问题，也推荐按照此篇博客进行配置：https://blog.csdn.net/bornfree5511/article/details/109275982"
    nvidia-smi && sleep 1s
    success
}

function config_virtualbox {
    echo -e "${BGreen}将要安装virtualbox${Color_Off}" && sleep 1s
    sudo apt install -y virtualbox
    success
}

#################################################################################################################
existstatus=$?

if [ $existstatus = 0 ]; then
   # echo $SELECT | grep "7" && echo "test success"
    echo $SELECT | grep "换源&Clean" && config_clean
    echo $SELECT | grep "键盘配置" && config_keyboard
    echo $SELECT | grep "Git" && config_git
    echo $SELECT | grep "Fish" && config_fish
    echo $SELECT | grep "搜狗拼音输入法" && config_sogou
    echo $SELECT | grep "VSCode" && config_vscode
    echo $SELECT | grep "代理软件" && config_proxy

    echo $SELECT | grep "Ubuntu美化" && config_beautify
    echo $SELECT | grep "Google Chrome" && config_chrome
    echo $SELECT | grep "Zotero" && config_zotero
    echo $SELECT | grep "ROS" && config_ROS
    echo $SELECT | grep "ROS2" && config_ROS2
    echo $SELECT | grep "Miniconda3" && config_miniconda
    echo $SELECT | grep "Nvidia显卡驱动" && config_nvidia
    echo $SELECT | grep "sysmonitor&stacer&backintime" && config_sysmonitor
    echo $SELECT | grep "VirtualBox" && config_virtualbox
    echo $SELECT | grep "Julia" && config_julia
    echo $SELECT | grep "kazam" && config_kazam
    echo $SELECT | grep "Vim配置" && config_vim
    echo $SELECT | grep "重命名folder" && config_folder
    echo $SELECT | grep "Isaacgym" && config_isaacgym
    
    if [ $Flag_Doc -eq 1 ]
    then 
        zenity --warning \
         --text="部分程序有一些额外说明，请阅读你的桌面上的【Ubuntu助手附加说明.txt】文件" 
    else
        echo -e "${BGreen}全部安装完成！${Color_Off}"
    fi


   
##################################################################################################################################

else
    echo "取消"
fi
