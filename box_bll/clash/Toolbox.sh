#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    echo "请设置以 Root 用户运行"
    exit 1
fi

SURFING_PATH="/data/adb/modules/Surfing/"
MODULE_PROP="${SURFING_PATH}module.prop"
GXSURFING_PATH="/data/adb/modules_update/Surfing"
SCRIPTS_PATH="/data/adb/box_bll/scripts/"
BOX_PATH="/data/adb/box_bll/scripts/box.config"
CONFIG_PATH="/data/adb/box_bll/clash/config.yaml"
CORE_PATH="/data/adb/box_bll/bin/clash"
COREE_PATH="/data/adb/box_bll/clash/"
VAR_PATH="/data/adb/box_bll/variab/"
BASEE_URL="https://github.com/MetaCubeX/mihomo/releases/download/"
RELEASE_PATH="mihomo-android-arm64-v8"
BASE_URL="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"
TEMP_FILE="/data/local/tmp/mihomo_latest.gz"
TEMP_DIR="/data/local/tmp/mihomo_update"
PANEL_DIR="/data/adb/box_bll/panel/"
META_DIR="${PANEL_DIR}Meta/"
META_URL="https://github.com/metacubex/metacubexd/archive/gh-pages.zip"
METAA_URL="https://api.github.com/repos/metacubex/metacubexd/releases/latest"
YACD_DIR="${PANEL_DIR}Yacd/"
YACD_URL="https://github.com/MetaCubeX/yacd/archive/gh-pages.zip"
YACDD_URL="https://api.github.com/repos/MetaCubeX/Yacd-meta/releases/latest"
TEMP_FILE="/data/local/tmp/ui_update.zip"
TEMP_DIR="/data/local/tmp/ui_update"
DB_PATH="/data/adb/box_bll/clash/cache.db"
SERVICE_SCRIPT="/data/adb/box_bll/scripts/box.service"
CLASH_RELOAD_URL="http://127.0.0.1:9090/configs"
CLASH_RELOAD_PATH="/data/adb/box_bll/clash/config.yaml"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
GEODATA_URL="https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest"
GEOIP_PATH="/data/adb/box_bll/clash/GeoIP.dat"
GEOSITE_PATH="/data/adb/box_bll/clash/GeoSite.dat"
RULES_PATH="/data/adb/box_bll/clash/rule/"
GIT_URL="https://api.github.com/repos/MoGuangYu/Surfing/releases/latest"
RULES_URL_PREFIX="https://raw.githubusercontent.com/MoGuangYu/rules/main/Home/"
RULES=("YouTube.yaml" "TikTok.yaml" "Telegram.yaml" "OpenAI.yaml" "Netflix.yaml" "Microsoft.yaml" "Google.yaml" "Facebook.yaml" "Discord.yaml" "Apple.yaml")

show_menu() {
    while true; do
        echo "=========="
        echo "v1.0"
        echo "Menu Bar："
        echo "1. 清空数据库缓存"
        echo "2. 更新 Web 面板"
        echo "3. 更新 Geo 数据库"
        echo "4. 更新 Apps 路由规则"
        echo "5. 更新 Clash 核心"
        echo "6. 进入 Telegram 频道"
        echo "7. Web 面板访问入口"
        echo "8. 整合 Magisk 更新状态"
        echo "9. 更新 Surfing 模块"
        echo "10. 重载配置"
        echo "11. Exit"
        echo "——————"
        read -r choice

        case $choice in
            1)
                clear_cache
                ;;
            2)
                update_web_panel
                ;;
            3)
                update_geo_database
                ;;
            4)
                update_rules
                ;;
            5)
                update_core
                ;;
            6)
                open_telegram_group
                ;;
            7)
                show_web_panel_menu
                ;;
            8)
                integrate_magisk_update
                ;;
            9)
                update_module
                ;;
            10)
                reload_configuration
                ;;
            11)
                exit 0
                ;;
            *)
                echo "无效的选择！"
                ;;
        esac
    done
}
integrate_magisk_update() {
    echo "↴"
    echo "如果你在 Magisk客户端 更新了模块，可手动进行整合刷新更新状态 无需重启手机，是否整合？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "操作取消！"
        return
    fi
    echo "↴"
    echo "正在检测更新状态..."
        for i in 2 1
    do
        sleep 1
    done
    
    if [ -d "$GXSURFING_PATH" ]; then
        echo "检测到更新 Surfing 模块，进行整合..."
        rm -rf "$SURFING_PATH"
        mv "$GXSURFING_PATH" /data/adb/modules/
        if [ -f "$SURFING_PATH/update" ]; then
            rm -f "$SURFING_PATH/update"
        fi    
        echo "整合成功✓"
    else
        echo "没有检测到更新 Surfing 模块。"
    fi
}
update_module() {
    echo "↴" 
    if [ -f "$MODULE_PROP" ]; then
        current_version=$(grep '^version=' "$MODULE_PROP" | cut -d'=' -f2)
        echo "当前模块版本号: $current_version"
    else
        echo "无法获取当前模块版本号，文件不存在。"
    fi
    echo "正在获取服务器中..."
    module_release=$(curl -s "$GIT_URL")
    module_version=$(echo "$module_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$module_version" ]; then
        echo "获取服务器失败！"
        echo "可能："
        echo "1h内请求次数过多 / 网络不稳定"
        show_menu
    fi
    download_url=$(echo "$module_release" | grep '"browser_download_url"' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "获取成功！"
    echo "当前最新版本号: $module_version"
    echo "是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "操作取消！"
        return
    fi
    echo "↴"
    echo "正在下载更新中..."
    curl -L -o "$TEMP_FILE" "$download_url"
    if [ $? -ne 0 ]; then
        echo "下载失败，请检查网络连接和URL！"
        exit 1
    fi
    echo "文件有效，开始进行更新..."
    mkdir -p "$TEMP_DIR"
    unzip -q "$TEMP_FILE" -d "$TEMP_DIR"
    if [ $? -ne 0 ]; then
        echo "解压失败，请检查下载的文件！"
        exit 1
    fi
    if [ -f "$BOX_PATH" ] || [ -f "$CONFIG_PATH" ]; then
        mv "$BOX_PATH" "${BOX_PATH}.bak"
        mv "$CONFIG_PATH" "${CONFIG_PATH}.bak"
    fi       
    mv "$TEMP_DIR/box_bll/scripts/"* "$SCRIPTS_PATH"
    chmod -R 0711 "${SCRIPTS_PATH}"
    chown -R root:net_admin "${SCRIPTS_PATH}"    
    mv "$TEMP_DIR/box_bll/clash/config.yaml" "$COREE_PATH"
    mv "$TEMP_DIR/box_bll/clash/enhanced_config.yaml" "$COREE_PATH"
    mv "$TEMP_DIR/box_bll/clash/Toolbox.sh" "$COREE_PATH"
    find "$TEMP_DIR" -mindepth 1 -maxdepth 1 ! -name "README.md" ! -name "Surfing_service.sh" ! -name "customize.sh" ! -name "box_bll" ! -name "META-INF" -exec cp -r {} "$SURFING_PATH" \;
    if [ -d "$TEMP_DIR/webroot" ]; then
      cp -r "$TEMP_DIR/webroot/"* "$SURFING_PATH/webroot/"
    fi
    if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10683 ]; then
        SERVICE_PATH="/data/adb/ksu/service.d"
    else 
        SERVICE_PATH="/data/adb/service.d"
    fi
    if [ ! -d "$SERVICE_PATH" ]; then
        mkdir -p "$SERVICE_PATH"
    fi
    mv "$TEMP_DIR/Surfing_service.sh" "$SERVICE_PATH"     
    chmod 0700 "${SERVICE_PATH}/Surfing_service.sh"
    rm -rf "$TEMP_FILE" "$TEMP_DIR"
    echo "更新成功✓"
    echo "重启模块服务中..."
    touch "${SURFING_PATH}disable"
    sleep 1.5
    rm -f "${SURFING_PATH}disable"
    sleep 1.5
    for i in 5 4 3 2 1
    do
        sleep 1
    done
    $SERVICE_SCRIPT status
    echo "ok"
}
clear_cache() {
    echo "↴"
    if [ ! -d "$VAR_PATH" ]; then
        mkdir -p "$VAR_PATH"
        if [ $? -ne 0 ]; then
            echo "创建路径失败，请检查权限！"
            exit 1
        fi
    fi  
    CACHE_CLEAR_TIMESTAMP="${VAR_PATH}last_cache_update.txt" 
    if [ -f "$CACHE_CLEAR_TIMESTAMP" ]; then
        last_clear=$(date -d "@$(cat $CACHE_CLEAR_TIMESTAMP)" +"%Y-%m-%d %H:%M:%S")
        echo "距离上次清空缓存是: $last_clear" 
    fi
    echo "此操作会清空数据库缓存，是否清除？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "操作取消！"
        return
    fi
    echo "↴"
    if [ -f "$DB_PATH" ]; then
        rm "$DB_PATH"
        echo "已清空数据库缓存✓"
        touch "$DB_PATH"
    else
        echo "数据库文件不存在..."
        touch "$DB_PATH"
        echo "已创建新的空数据库文件"
    fi
    echo "重启模块服务中..."
    touch "$SURFING_PATH/disable"
    sleep 1.5
    rm -f "$SURFING_PATH/disable"
    sleep 1.5
    for i in 5 4 3 2 1
    do
        sleep 1
    done
    $SERVICE_SCRIPT status
    echo "ok"
    date +%s > "$CACHE_CLEAR_TIMESTAMP"
}
update_geo_database() {
    echo "↴"  
    if [ ! -d "$VAR_PATH" ]; then   
        mkdir -p "$VAR_PATH"
        if [ $? -ne 0 ]; then
            echo "创建路径失败，请检查权限！"
            exit 1
        fi
    fi
    GEO_DATABASE_VERSION_FILE="${VAR_PATH}geo_database_update.txt"
    if [ -f "$GEO_DATABASE_VERSION_FILE" ]; then
        last_version=$(cat "$GEO_DATABASE_VERSION_FILE")
        echo "距离上次更新的版本号是: $last_version"
    fi
    echo "正在获取服务器中..."
    geo_release=$(curl -s "$GEODATA_URL")
    geo_version=$(echo "$geo_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$geo_version" ]; then
        echo "获取服务器失败！"
        echo "可能："
        echo "1h内请求次数过多 / 网络不稳定"
        show_menu
    fi       
    echo "获取成功！"
    echo "当前最新版本号: $geo_version"
    echo "是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "操作取消！"
        return
    fi
    echo "↴"
    if [ -f "/data/adb/box_bll/clash/geosite.dat" ]; then
        rm "/data/adb/box_bll/clash/geosite.dat"
    fi
    if [ -f "/data/adb/box_bll/clash/geoip.dat" ]; then
        rm "/data/adb/box_bll/clash/geoip.dat"
    fi
    echo "正在下载更新中..."
    curl -o "$GEOIP_PATH" -L "$GEOIP_URL"
    if [ $? -ne 0 ]; then
        echo "下载 GeoIP.dat 失败！"
        return
    fi
    curl -o "$GEOSITE_PATH" -L "$GEOSITE_URL"
    if [ $? -ne 0 ]; then
        echo "下载 GeoSite.dat 失败！"
        return
    fi
    echo "更新成功✓"
    echo ""
    echo "建议重载配置..."
    chown root:net_admin "$GEOIP_PATH" "$GEOSITE_PATH"
    chmod 0644 "$GEOIP_PATH" "$GEOSITE_PATH"
    if [ $? -ne 0 ]; then
        echo "设置文件权限失败！"
        return
    fi
    echo "$geo_version" > "$GEO_DATABASE_VERSION_FILE"
}
update_rules() {
    echo "↴"
    if [ ! -d "$VAR_PATH" ]; then   
        mkdir -p "$VAR_PATH"
        if [ $? -ne 0 ]; then
            echo "创建路径失败，请检查权限！"
            exit 1
        fi
    fi     
    RULES_UPDATE_TIMESTAMP="${VAR_PATH}last_rules_update.txt"    
    if [ -f "$RULES_UPDATE_TIMESTAMP" ]; then
        last_update=$(date -d "@$(cat $RULES_UPDATE_TIMESTAMP)" +"%Y-%m-%d %H:%M:%S")
        echo "距离上次更新是: $last_update"
    fi
    echo "此操作会从 GitHub 拉取最新全部规则，是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ];then
        echo "操作取消！"
        return
    fi
    if [ ! -d "$RULES_PATH" ];then
        echo "目录不存在，正在创建..."
        mkdir -p "$RULES_PATH"
        if [ $? -ne 0 ];then
            echo "创建规则目录失败，请检查权限！"
            return
        fi
    fi
    echo "↴"
    echo "正在下载更新中..."
    for rule in "${RULES[@]}"; do
        curl -o "${RULES_PATH}${rule}" -L "${RULES_URL_PREFIX}${rule}"
        if [ $? -ne 0 ];then
            echo "下载 ${rule} 失败！"
            return
        fi
    done
    echo "更新成功✓"
    echo ""
    echo "建议重载配置..."
    chown -R root:net_admin "$RULES_PATH"
    find "$RULES_PATH" -type d -exec chmod 0755 {} \;
    find "$RULES_PATH" -type f -exec chmod 0666 {} \;
    if [ $? -ne 0 ];then
        echo "设置文件权限失败！"
        return
    fi
    date +%s > "$RULES_UPDATE_TIMESTAMP"
}
show_web_panel_menu() {
    while true; do
        echo "↴"
        echo "选择图形面板："
        echo "1. HTTPS Gui Meta"
        echo "2. HTTPS Gui Yacd"
        echo "3. 本地端口 >>> 127.0.0.1:9090/ui"
        echo "4. 返回上一级菜单"
        read -r web_choice
        case $web_choice in
            1)
                echo "↴"
                echo "正在跳转到 Gui Meta..."
                am start -a android.intent.action.VIEW -d "https://metacubex.github.io/metacubexd"
                echo "ok"
                echo ""
                ;;
            2)
                echo "↴"
                echo "正在跳转到 Gui Yacd..."
                am start -a android.intent.action.VIEW -d "https://yacd.metacubex.one/"
                echo "ok"
                echo ""
                ;;
            3)
                echo "↴"
                echo "正在跳转到本地端口..."
                am start -a android.intent.action.VIEW -d "http://127.0.0.1:9090/ui/#/"
                echo "ok"
                echo ""
                ;;
            4)
                return
                ;;
            *)
                echo "无效的选择！"
                ;;
        esac
    done
}
open_telegram_group() {
    echo "↴"
    echo "正在跳转到 Surfing..."
    am start -a android.intent.action.VIEW -d "https://t.me/+vvlXyWYl6HowMTBl"
    echo "ok"
}
update_web_panel() {
    echo "↴"
    if [ ! -d "$VAR_PATH" ]; then 
        mkdir -p "$VAR_PATH"
        if [ $? -ne 0 ]; then
            echo "创建路径失败，请检查权限！"
            exit 1
        fi
    fi
    WEB_PANEL_TIMESTAMP="${VAR_PATH}last_web_panel_update.txt"
    if [ -f "$WEB_PANEL_TIMESTAMP" ]; then
        last_update=$(cat "$WEB_PANEL_TIMESTAMP")
        echo "距离上次更新的 Meta 版本号是: $(echo $last_update | cut -d ' ' -f 1)"
        echo "距离上次更新的 Yacd 版本号是: $(echo $last_update | cut -d ' ' -f 2)"
    fi
    echo "正在获取服务器中..."
    meta_release=$(curl -s "$METAA_URL")
    meta_version=$(echo "$meta_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    yacd_release=$(curl -s "$YACDD_URL")
    yacd_version=$(echo "$yacd_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$meta_version" ] || [ -z "$yacd_version" ]; then
        echo "获取服务器失败！"
        echo "可能："
        echo "1h内请求次数过多 / 网络不稳定"
        show_menu
    fi  
    echo "获取成功！"   
    echo "Meta 当前最新版本号: $meta_version"
    echo "Yacd 当前最新版本号: $yacd_version"
    echo "是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "操作取消！"
        return
    fi    
    echo "↴"
    echo "Update Web panel：Meta"
    if [ ! -d "$META_DIR" ]; then
        echo "目录不存在，正在创建..."
        mkdir -p "$META_DIR"
        if [ $? -ne 0 ]; then
            echo "创建目录失败，请检查权限！"
            return
        fi
    fi
    echo "正在拉取最新的代码..."
    curl -L -o "$TEMP_FILE" "$META_URL"
    if [ $? -eq 0 ]; then
        echo "下载成功，正在效验文件..."
        if [ -s "$TEMP_FILE" ]; then
            echo "文件有效，开始进行更新..."
            unzip -q "$TEMP_FILE" -d "$TEMP_DIR"
            if [ $? -eq 0 ]; then
                rm -rf "${META_DIR:?}"/*
                if [ $? -ne 0 ]; then
                    echo "操作失败，请检查权限！"
                    return
                fi
                mv "$TEMP_DIR/metacubexd-gh-pages/"* "$META_DIR"
                rm -rf "$TEMP_DIR"
                rm "$TEMP_FILE"
                echo "更新成功✓"
                echo ""
            else
                echo "解压失败！"
            fi
        else
            echo "下载的文件为空或无效！"
        fi
    else
        echo "拉取下载失败！"
    fi   
    echo "Update Web panel：Yacd"
    if [ ! -d "$YACD_DIR" ]; then
        echo "目录不存在，正在创建..."
        mkdir -p "$YACD_DIR"
        if [ $? -ne 0 ]; then
            echo "创建目录失败，请检查权限！"
            return
        fi
    fi
    echo "正在拉取最新的面板代码..."
    curl -L -o "$TEMP_FILE" "$YACD_URL"
    if [ $? -eq 0 ]; then
        echo "下载成功，正在效验文件..."
        if [ -s "$TEMP_FILE" ]; then
            echo "文件有效，开始进行更新..."
            unzip -q "$TEMP_FILE" -d "$TEMP_DIR"
            if [ $? -eq 0 ]; then
                rm -rf "${YACD_DIR:?}"/*
                if [ $? -ne 0 ]; then
                    echo "操作失败，请检查权限！"
                    return
                fi
                mv "$TEMP_DIR/Yacd-meta-gh-pages/"* "$YACD_DIR"
                rm -rf "$TEMP_DIR"
                rm "$TEMP_FILE"
                echo "更新成功✓"
                echo ""
                echo "建议重载配置..."
            else
                echo "解压失败！"
            fi
        else
            echo "下载的文件为空或无效！"
        fi
    else
        echo "拉取下载失败！"
    fi 
    chown -R root:net_admin "$PANEL_DIR"
    find "$PANEL_DIR" -type d -exec chmod 0755 {} \;
    find "$PANEL_DIR" -type f -exec chmod 0666 {} \;
    if [ $? -ne 0 ]; then
        echo "设置文件权限失败！"
        return
    fi
    echo "$meta_version $yacd_version" > "$WEB_PANEL_TIMESTAMP"
}
reload_configuration() {
    echo "↴"
    echo "正在重载 Clash 配置..."
    curl -X PUT "$CLASH_RELOAD_URL" -d "{\"path\":\"$CLASH_RELOAD_PATH\"}"

    if [ $? -eq 0 ];then
        echo "ok"
    else
        echo "重载失败！"
    fi
}
update_core() {
    echo "↴"
    if [ ! -d "$VAR_PATH" ]; then
        mkdir -p "$VAR_PATH"
        if [ $? -ne 0 ]; then
            echo "创建路径失败，请检查权限！"
            exit 1
        fi
    fi
    CORE_TIMESTAMP="${VAR_PATH}last_core_update.txt"
    if [ -f "$CORE_TIMESTAMP" ]; then
        last_update=$(cat "$CORE_TIMESTAMP")
        echo "距离上次更新的版本号是: $last_update"
    fi
    echo "正在获取服务器中..."
    latest_release=$(curl -s "$BASE_URL")
    latest_version=$(echo "$latest_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$latest_version" ]; then
        echo "服务器连接失败！"
        echo "可能："
        echo "1h内请求次数过多 / 网络不稳定"
        show_menu
        return
    fi
    download_url="${BASEE_URL}${latest_version}/${RELEASE_PATH}-${latest_version}.gz"
    echo "获取成功！"
    echo "当前最新版本号: $latest_version"
    echo "是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "操作取消！"
        return
    fi
    echo "↴"
    echo "正在下载更新中..."
    curl -L -o "$TEMP_FILE" "$download_url"
    if [ $? -ne 0 ]; then
        echo "下载失败，请检查网络连接和URL！"
        exit 1
    fi
    file_size=$(stat -c%s "$TEMP_FILE")
    if [ "$file_size" -le 100 ]; then
        echo "下载的文件大小异常，请检查下载链接是否正确！"
        exit 1
    fi
    echo "文件有效，开始进行更新..."
    mkdir -p "$TEMP_DIR"
    gunzip -c "$TEMP_FILE" > "$TEMP_DIR/clash"
    if [ $? -ne 0 ]; then
        echo "解压失败，请检查下载的文件！"
        exit 1
    fi
    chown root:net_admin "$TEMP_DIR/clash"
    chmod 0700 "$TEMP_DIR/clash"
    if [ -f "$CORE_PATH" ]; then
        mv "$CORE_PATH" "${CORE_PATH}.bak"
    fi
    mv "$TEMP_DIR/clash" "$CORE_PATH"
    rm -rf "$TEMP_FILE" "$TEMP_DIR"
    echo "更新成功✓"
    echo ""
    echo "重启模块服务中..."
    touch "${SURFING_PATH}disable"
    sleep 1.5
    rm -f "${SURFING_PATH}disable"
    sleep 1.5
    for i in 5 4 3 2 1; do
        sleep 1
    done
    $SERVICE_SCRIPT status
    echo "ok"
    echo "$latest_version" > "$CORE_TIMESTAMP"
}
show_menu
