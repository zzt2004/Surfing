#!/bin/bash

# 注意！！！
# 此脚本需要 curl 命令，请确保在运行之前设备已经安装了 curl 命令，并以root权限执行此脚本
# 可先尝试执行，如没有可使用以下命令在 Termux App 中安装
# 终端依次执行以下命令
# --------------------------
# pkg update
# pkg install curl
# --------------------------  
# 安装过程如有选择性提示都是选择 Y 回车即可.
# Termux App 官方下载地址：https://f-droid.org/repo/com.termux_118.apk

# 检查是否已经具有 root 权限
if [ "$(id -u)" -eq 0 ]; then
    echo "已经具有 root 权限"
else
    echo "请求获取 root 权限..."
    su -c "$0 $@"
    exit
fi

# 定义数据库文件的下载链接
geoip_url="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
geosite_url="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
mmdb_url="https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb"

# 定义数据库文件的存放路径
database_dir="/data/adb/box_bll/clash/"

# 下载数据库文件并覆盖旧文件
download_and_replace() {
    local url="$1"
    local file_name="$2"
    
    echo "正在更新 $file_name ..."
    curl -L "$url" -o "$database_dir/$file_name"
    
    if [ $? -eq 0 ]; then
        echo "$file_name 更新成功！"
        return 0
    else
        echo "$file_name 更新失败！"
        return 1
    fi
}

# 执行数据库文件更新操作
update_database() {
    # 下载数据库文件并覆盖旧文件
    download_and_replace "$geoip_url" "geoip.dat"
    download_and_replace "$geosite_url" "geosite.dat"
    download_and_replace "$mmdb_url" "country.mmdb"
}

# 主程序入口
main() {
    echo "正在自动更新Geo数据库文件..."
    
    # 切换到数据库文件目录
    cd "$database_dir"
    
    # 更新数据库文件
    update_database
    
    echo "自动更新完成！"
}

# 执行主程序
main
