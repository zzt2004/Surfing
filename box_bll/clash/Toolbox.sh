#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    echo "请设置以 Root 用户运行"
    exit 1
fi

SURFING_PATH="/data/adb/modules/Surfing/"
MODULE_PROP="${SURFING_PATH}module.prop"
GXSURFING_PATH="/data/adb/modules_update/Surfing"
NET_PATH="/data/misc/net"
CTR_PATH="/data/misc/net/rt_tables"
SCRIPTS_PATH="/data/adb/box_bll/scripts/"
BOX_PATH="/data/adb/box_bll/scripts/box.config"
CONFIG_PATH="/data/adb/box_bll/clash/config.yaml"
CORE_PATH="/data/adb/box_bll/bin/clash"
COREE_PATH="/data/adb/box_bll/clash/"
VAR_PATH="/data/adb/box_bll/variab/"
BASEE_URL="https://github.com/MetaCubeX/mihomo/releases/download/"
RELEASE_PATH="mihomo-android-arm64-v8"
BASE_URL="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"
PANEL_DIR="/data/adb/box_bll/panel/"
META_DIR="${PANEL_DIR}Meta/"
CHANGELOG_URL="https://raw.githubusercontent.com/MoGuangYu/Surfing/main/changelog.md"
META_URL="https://github.com/metacubex/metacubexd/archive/gh-pages.zip"
METAA_URL="https://api.github.com/repos/metacubex/metacubexd/releases/latest"
YACD_DIR="${PANEL_DIR}Yacd/"
YACD_URL="https://github.com/MetaCubeX/yacd/archive/gh-pages.zip"
YACDD_URL="https://api.github.com/repos/MetaCubeX/Yacd-meta/releases/latest"
ZASH_DIR="${PANEL_DIR}Zash/"
ZASH_URL="https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip"
ZASHD_URL="https://api.github.com/repos/Zephyruso/zashboard/releases/latest"
BACKUP_FILE="$COREE_PATH/subscribe_urls_backup.txt"
TEMP_FILE="/data/local/tmp/Surfing_update.zip"
TEMP_DIR="/data/local/tmp/Surfing_update"
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

CURRENT_VERSION="v12.0"
TOOLBOX_URL="https://raw.githubusercontent.com/MoGuangYu/Surfing/main/box_bll/clash/Toolbox.sh"
TOOLBOX_FILE="/data/adb/box_bll/clash/Toolbox.sh"


get_remote_version() {
    remote_content=$(curl -s --connect-timeout 3 "$TOOLBOX_URL")
    if [ $? -ne 0 ]; then
        echo "无法连接到 GitHub！"
        return 1
    fi
    remote_version=$(echo "$remote_content" | grep -Eo 'CURRENT_VERSION="v[0-9]+(\.[0-9]+)?"' | head -1 | cut -d'=' -f2 | tr -d '"')
    if [ -z "$remote_version" ]; then
        echo "无法获取远程版本信息！"
        return 1
    fi
    echo "$remote_version"
    return 0
}
check_version() {
    remote_version=$(get_remote_version)
    if [ $? -ne 0 ]; then
        return
    fi
    if [ "$(echo "$remote_version" | cut -d'v' -f2)" != "$(echo "$CURRENT_VERSION" | cut -d'v' -f2)" ]; then
        echo "Toolbox"
        echo "当前版本版本: $CURRENT_VERSION"
        echo "远程最新版本: $remote_version"
        echo "是否更新脚本？回复y/n"
        read -r update_confirmation
        if [ "$update_confirmation" = "y" ]; then
            echo "↴" 
            echo "正在从 GitHub 下载最新版本..."
            curl -sS -L -o "$TOOLBOX_FILE" "$TOOLBOX_URL"
            if [ $? -ne 0 ]; then
                echo "下载失败，请检查网络连接是否能正常访问 GitHub！"
                exit 1
            fi
            chmod 0644 "$TOOLBOX_FILE"
            echo "正在运行最新版本的脚本！"
            exec sh "$TOOLBOX_FILE"
            exit 0
        else
            echo "↴" 
            echo "更新取消"
            echo "继续使用当前脚本！"
        fi
    fi
}
check_version

extract_subscribe_urls() {
    if [ -f "$CONFIG_PATH" ]; then
        echo "正在提取订阅地址..."
        awk '/proxy-providers:/,/^proxies:/' "$CONFIG_PATH" | grep -Eo "url: \".*\"" | sed -E 's/url: "(.*)"/\1/' > "$BACKUP_FILE"
        
        if [ -s "$BACKUP_FILE" ]; then
            echo "订阅地址已备份到:"
            echo "$BACKUP_FILE"
        else
            echo "未找到目标 URL，请检查配置文件格式"
            rm -f "$BACKUP_FILE"
        fi
    else
        echo "配置文件不存在，无法提取订阅地址"
    fi
}
restore_subscribe_urls() {
    if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
        echo "正在恢复订阅地址..."
        awk -v backup="$BACKUP_FILE" '
            BEGIN {
                while ((getline url < backup) > 0) {
                    urls[++n] = url
                }
                close(backup)
                i = 0
            }
            /proxy-providers:/ { in_provider = 1 }
            in_provider && /url:/ {
                if (++i <= n) {
                    sub(/url: ".*"/, "url: \"" urls[i] "\"")
                }
            }
            /proxies:/ { in_provider = 0 }
            { print }
        ' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && \
        mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"

        echo "订阅地址已恢复 >> 新配置中！"
    else
        echo "配置文件不存在，无法提取订阅地址"
    fi
}
reload_configuration() {
       if [ ! -f "$MODULE_PROP" ]; then
          echo "↴" 
          echo "当前未安装模块！"
          return
       fi
       if [ -f "/data/adb/modules/Surfing/disable" ]; then
          echo "↴" 
          echo "服务未运行，重载操作失败！"
          return
       fi
          echo "↴"
          echo "正在重载 Clash 配置..."
          curl -X PUT "$CLASH_RELOAD_URL" -d "{\"path\":\"$CLASH_RELOAD_PATH\"}"
       if [ $? -eq 0 ]; then
          echo "ok"
       else
          echo "重载失败！"
       fi
    }

update_module() {
    echo "↴"
    module_installed=true
    if [ -f "$MODULE_PROP" ]; then
        current_version=$(grep '^version=' "$MODULE_PROP" | cut -d'=' -f2)
        echo "当前模块版本号: $current_version"
    else
        module_installed=false
        echo "当前设备没有安装 Surfing 模块"
        echo "是否下载安装？回复y/n"
        read -r install_confirmation
        if [ "$install_confirmation" != "y" ]; then
            echo "↴"
            echo "操作取消！"
            return
        fi
    fi

    echo "↴"
    echo "正在获取服务器中..."
    module_release=$(curl -s "$GIT_URL")
    module_version=$(echo "$module_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$module_version" ]; then
        echo "获取服务器失败！"
        echo "错误：API 速率受限 / 网络异常 ！"
        return
    fi
    download_url=$(echo "$module_release" | grep '"browser_download_url".*release' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "获取成功！"
    echo "当前最新版本号: $module_version"

    if [ "$module_installed" = true ] && [ "$current_version" = "$module_version" ]; then
        echo "当前已是最新版本！"
        return
    fi

    changelog=$(curl -s "$CHANGELOG_URL")
    latest_changelog=$(echo "$changelog" | awk '/^## /{p=0} p; /^## '$module_version'$/{p=1}')
    echo "$latest_changelog"
    echo ""

    if [ "$module_installed" = false ]; then
        echo "是否安装模块？回复y/n"
    else
        echo "是否更新模块？回复y/n"
    fi
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        echo "操作取消！"
        return
    fi

    echo "↴"
    echo "正在下载文件中..."
    if ! curl -sS -L -o "$TEMP_FILE" "$download_url"; then
        echo "下载失败，请检查网络连接是否能正常访问 GitHub！"
        return
    fi

    echo "文件效验通过，开始处理..."
    mkdir -p "$TEMP_DIR"
    if ! unzip -qo "$TEMP_FILE" -d "$TEMP_DIR"; then
        echo "解压失败，文件异常！"
        rm -rf "$TEMP_FILE" "$TEMP_DIR"
        return
    fi

    if [ -d /data/adb/box_bll/clash ]; then
        extract_subscribe_urls
    fi

    if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10683 ]; then
        SERVICE_PATH="/data/adb/ksu/service.d"
    else 
        SERVICE_PATH="/data/adb/service.d"
    fi
    mkdir -p "$SERVICE_PATH"
    mv "$TEMP_DIR/Surfing_service.sh" "$SERVICE_PATH"
    chmod 0700 "${SERVICE_PATH}/Surfing_service.sh"

    if [ -d /data/adb/box_bll ]; then
        mkdir -p "$SCRIPTS_PATH"
        mkdir -p "$COREE_PATH"
        mkdir -p "$SURFING_PATH"
        mkdir -p "$SURFING_PATH/webroot"

        [ -f "$CONFIG_PATH" ] && mv "$CONFIG_PATH" "${CONFIG_PATH}.bak"
        [ -f "$BOX_PATH" ] && mv "$BOX_PATH" "${BOX_PATH}.bak"

        mv "$TEMP_DIR/box_bll/scripts/"* "$SCRIPTS_PATH"
        mv "$TEMP_DIR/box_bll/clash/config.yaml" "$COREE_PATH"

        find "$TEMP_DIR" -mindepth 1 -maxdepth 1 ! -name "README.md" ! -name "Surfing_service.sh" ! -name "customize.sh" ! -name "box_bll" ! -name "META-INF" -exec cp -r {} "$SURFING_PATH" \;

        [ -d "$TEMP_DIR/webroot" ] && cp -r "$TEMP_DIR/webroot/"* "$SURFING_PATH/webroot/"

        restore_subscribe_urls
        reload_configuration
    else
        mkdir -p "$SURFING_PATH"
        mv "$TEMP_DIR/box_bll" "/data/adb/"
        mv "$TEMP_DIR/webroot" "$SURFING_PATH"
        find "$TEMP_DIR" -mindepth 1 -maxdepth 1 ! -name "README.md" ! -name "Surfing_service.sh" ! -name "customize.sh" ! -name "box_bll" ! -name "META-INF" -exec cp -r {} "$SURFING_PATH" \;
    fi

    chown -R root:net_admin /data/adb/box_bll/
    find /data/adb/box_bll/ -type d -exec chmod 755 {} \;
    find /data/adb/box_bll/ -type f -exec chmod 644 {} \;
    chmod -R 711 /data/adb/box_bll/scripts/
    chmod -R 700 /data/adb/box_bll/bin/

    rm -rf "$TEMP_FILE" "$TEMP_DIR"

    for pid in $(pidof inotifyd); do
        if grep -q box.inotify /proc/${pid}/cmdline; then
            kill ${pid}
        fi
    done

    nohup inotifyd "${SCRIPTS_PATH}box.inotify" "$SURFING_PATH" > /dev/null 2>&1 &
    nohup inotifyd "${SCRIPTS_PATH}net.inotify" "$NET_PATH" > /dev/null 2>&1 &
    nohup inotifyd "${SCRIPTS_PATH}ctr.inotify" "$CTR_PATH" > /dev/null 2>&1 &

    if [ "$module_installed" = false ]; then
        echo "安装成功✓"
    else
        echo "更新成功✓"
    fi
    echo "无需重启设备..."

}
update_module


GITHUB_REPO="MoGuangYu/Surfing"
SCRIPTS_PATH="box_bll/scripts"
CLASH_PATH="box_bll/clash"
LOCAL_SCRIPTS_DIR="/data/adb/box_bll/scripts"
LOCAL_CLASH_DIR="/data/adb/box_bll/clash"
CONFIG_PATH="$LOCAL_CLASH_DIR/config.yaml"
BACKUP_FILE="$LOCAL_CLASH_DIR/subscribe_urls_backup.txt"
LOCAL_SHA_DIR="/data/adb/box_bll/variab/sha_cache"

all_up_to_date=true
rate_limit_exceeded=false
net_error=false

echo ""
echo "↴"
echo "正在获取 MoGuangYu/Surfing 仓库最新提交："
echo ""

if [ ! -d "$LOCAL_SHA_DIR" ]; then
    echo "↴"
    echo "警告："
    echo "检测到你是第一次获取"
    echo "需执行遍历更新获取文件Sha值缓存"
    echo ""
fi

FILES=(
    "$SCRIPTS_PATH/box.config|$LOCAL_SCRIPTS_DIR/box.config|backup"
    "$SCRIPTS_PATH/box.inotify|$LOCAL_SCRIPTS_DIR/box.inotify"
    "$SCRIPTS_PATH/box.service|$LOCAL_SCRIPTS_DIR/box.service"
    "$SCRIPTS_PATH/box.tproxy|$LOCAL_SCRIPTS_DIR/box.tproxy"
    "$SCRIPTS_PATH/ctr.inotify|$LOCAL_SCRIPTS_DIR/ctr.inotify"
    "$SCRIPTS_PATH/ctr.utils|$LOCAL_SCRIPTS_DIR/ctr.utils"
    "$SCRIPTS_PATH/net.inotify|$LOCAL_SCRIPTS_DIR/net.inotify"
    "$SCRIPTS_PATH/start.sh|$LOCAL_SCRIPTS_DIR/start.sh"
    "$CLASH_PATH/config.yaml|$LOCAL_CLASH_DIR/config.yaml|backup"
)

get_file_commit_info() {
    file_path="$1"
    commit_info=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/commits?path=$file_path" | grep -E '"message":' | head -1 | cut -d '"' -f4)
    if [ -z "$commit_info" ]; then
        echo "无法获取Git $file_path 的提交信息！"
        return 1
    fi
    echo "$commit_info"
    return 0
}

get_file_commit_sha() {
    file_path="$1"
 
    http_status=$(curl -s -I -o /dev/null -w "%{http_code}" "https://api.github.com/repos/$GITHUB_REPO/commits?path=$file_path")
    curl_status=$?

    if [ $curl_status -ne 0 ]; then
        echo "无法连接到GitHub，请检查网络连接！"
        return 3
    fi

    if [ "$http_status" = "403" ]; then
        rate_limit_exceeded=true
        all_up_to_date=false
        return 2
    elif [ "$http_status" != "200" ]; then
        echo "无法获取Git $file_path 的最新提交信息！HTTP 状态码: $http_status"
        return 1
    fi

    latest_sha=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/commits?path=$file_path" | grep '"sha"' | head -1 | cut -d '"' -f4)
    if [ $? -ne 0 ]; then
        echo "获取SHA时发生网络错误！"
        return 4
    fi

    if [ -z "$latest_sha" ]; then
        echo "无法获取Git $file_path 的最新提交信息！"
        return 1
    fi
    echo "$latest_sha"
    return 0
}

backup_file() {
    local_file="$1"
    if [ -f "$local_file" ]; then
        backup_file="${local_file}.bak"
        cp "$local_file" "$backup_file"
        echo "↴"
        echo "Backup >>> $backup_file"
    fi
}

check_and_update_files() {
    for file_entry in "${FILES[@]}"; do
        if $rate_limit_exceeded || $net_error; then
            break
        fi
        
        IFS='|' read -r file_path local_path need_backup <<< "$file_entry"
        local_sha_file="$LOCAL_SHA_DIR/$(basename "$local_path")_sha"

        latest_sha=$(get_file_commit_sha "$file_path")
        ret=$?

        if [ $ret -eq 3 ] || [ $ret -eq 4 ]; then
            echo "网络连接异常，终止更新！"
            net_error=true
            break

        elif [ $ret -eq 2 ]; then
            rate_limit_exceeded=true
            all_up_to_date=false
            break
        elif [ $ret -ne 0 ]; then
            continue
        fi
        
        if [ -f "$local_sha_file" ]; then
            current_sha=$(cat "$local_sha_file")
            if [ "$latest_sha" = "$current_sha" ]; then
                continue
            fi
        fi

        all_up_to_date=false

        echo "GitMain >>> $(basename "$local_path") "
        commit_info=$(get_file_commit_info "$file_path")
        echo ""
        echo "提交信息: "
        echo "$commit_info"
        echo "——————————"

        while true; do
            echo "是否同步更新？(y/n/x)"
            read -r user_response
            case "$user_response" in
                y|Y|n|N|x|X)
                    break
                    ;;
                *)
                    echo "无效选项！"
                    ;;
            esac
        done

        if [ "$user_response" = "x" ] || [ "$user_response" = "X" ]; then
            echo "↴"
            echo "跳过此次所有检测"
            break
        elif [ "$user_response" = "n" ] || [ "$user_response" = "N" ]; then
            echo "↴"
            echo "跳过此"
            echo ""
            continue
        fi
        
        if [ "$need_backup" = "backup" ]; then
            backup_file "$local_path"
            if [ "$local_path" = "$CONFIG_PATH" ]; then
                extract_subscribe_urls
            fi
        fi

        echo "↴"
        echo "下载中..."
        if [ ! -d "$LOCAL_SHA_DIR" ]; then
            mkdir -p "$LOCAL_SHA_DIR" || {
                echo "无法创建目录: $LOCAL_SHA_DIR"
                exit 1
            }
        fi
        
        if ! curl -sS -L -o "$local_path" "https://raw.githubusercontent.com/$GITHUB_REPO/main/$file_path"; then
            echo "下载失败，请检查网络连接！"
            net_error=true
            break
        else
            echo "更新完成 ✓"

            if [ "$local_path" = "$CONFIG_PATH" ]; then
                restore_subscribe_urls
                reload_configuration
            fi
            echo "$latest_sha" > "$local_sha_file"
        fi
        echo ""
    done
}
check_and_update_files

if $net_error; then
    echo "警告："
    echo "网络连接失败"
    echo "请检查网络连接后重试！"
elif $rate_limit_exceeded; then
    echo "警告："
    echo "GitHub API 速率限制已用尽！"
    echo "当前 IP 请求次数过多，请更换 IP 或等待 1 小时后重试！"
elif $all_up_to_date; then
    echo "获取成功！"
    echo "当前所有文件已是最新"
else
    if [ -d "$LOCAL_SHA_DIR" ] && [ -n "$(find "$LOCAL_SHA_DIR" -type f)" ]; then
        echo "↴"
        echo "部分文件已是更新"
    fi
fi
echo ""
echo "检测已完毕..."

show_menu() {
    while true; do
        echo "=========="
        echo "Menu：$CURRENT_VERSION"
        echo ""
        echo "1. 重载配置"
        echo ""
        echo "2. 清空数据库缓存"
        echo ""
        echo "3. 更新控制台面板"
        echo ""
        echo "4. 更新数据库"
        echo ""
        echo "5. 更新路由规则"
        echo ""
        echo "6. 更新核心"
        echo ""
        echo "7. 少儿频道"
        echo ""
        echo "8. 控制台面板入口"
        echo ""
        echo "9. 整合客户端更新状态"
        echo ""
        echo "10. 禁用/启用 更新模块"
        echo ""
        echo "11. 项目地址"
        echo ""
        echo "12. Exit"
        echo "——————"
        read -r choice
        case $choice in
            1)
                reload_configuration
                ;;
            2)
                clear_cache
                ;;
            3)
                update_web_panel
                ;;  
            4)
                update_geo_database
                ;;
            5)
                update_rules
                ;;
            6)
                update_core
                ;;
            7)
                open_telegram_group
                ;;
            8)
                show_web_panel_menu
                ;;
            9)
                integrate_magisk_update
                ;;
            10)
                if ! check_module_installed; then
                    continue
                fi
                check_update_status
                echo "1. 禁用更新"
                echo "2. 启用更新"
                read -r update_choice
                case $update_choice in
                    1)
                        disable_updates
                        ;;
                    2)
                        enable_updates
                        ;;
                    *)
                        echo "↴"
                        echo "无效的选择！"
                        ;;
                esac
                ;;
            11)
                open_project_page
                ;;
            12)
                exit 0
                ;;
            *)
                echo "↴"
                echo "无效的选择！"
                ;;
        esac
    done
}
NO_UPDATE_ENABLED=true
ensure_var_path() {
    if [ ! -d "$VAR_PATH" ]; then
        mkdir -p "$VAR_PATH"
        if [ $? -ne 0 ]; then
            echo "操作失败，请检查权限！"
            exit 1
        fi
    fi
}
check_module_installed() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return 1 
    fi
    return 0
}
check_update_status() {
    ensure_var_path
    UPDATE_STATUS_FILE="${VAR_PATH}/update_status"
    if [ -f "$UPDATE_STATUS_FILE" ]; then
        echo "↴" 
        echo "当前客户端状态：更新已禁用"
    else
        echo "↴" 
        echo "当前客户端状态：更新已启用"
    fi
}
disable_updates() {
    ensure_var_path
    UPDATE_STATUS_FILE="${VAR_PATH}/update_status"
    MODULE_PROP="${MODULE_PROP}"
    if grep -q "^updateJson=" "$MODULE_PROP"; then
        echo "↴" 
        echo "此操作会对该模块在客户端禁止检测更新，是否继续？回复y/n"
        read -r confirmation
        if [ "$confirmation" != "y" ]; then
            echo "↴"
            echo "操作取消！"
            return
        fi
        updateJson_value=$(grep "^updateJson=" "$MODULE_PROP" | cut -d '=' -f 2-)
        echo "$updateJson_value" > "$UPDATE_STATUS_FILE"
        sed -i '/^updateJson=/d' "$MODULE_PROP"
        echo "↴"
        echo "更新检测已禁止✓"
    else
        echo "↴" 
        echo "当前已是禁用状态，无需操作。"
    fi
}
enable_updates() {
    ensure_var_path
    UPDATE_STATUS_FILE="${VAR_PATH}/update_status"
    MODULE_PROP="${MODULE_PROP}"
    if [ -f "$UPDATE_STATUS_FILE" ]; then
        echo "↴" 
        echo "此操作会恢复模块在客户端的检测更新，是否继续？回复y/n"
        read -r confirmation
        if [ "$confirmation" != "y" ];then
            echo "↴"
            echo "操作取消！"
            return
        fi
        updateJson_value=$(cat "$UPDATE_STATUS_FILE")
        echo "updateJson=$updateJson_value" >> "$MODULE_PROP"
        rm -f "$UPDATE_STATUS_FILE"
        echo "↴"
        echo "更新检测已恢复✓"
    else
        echo "↴" 
        echo "当前已是启用状态，无需操作。"
    fi
}
integrate_magisk_update() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    echo "如果你在客户端 安装/更新 模块，可进行整合刷新并更新状态 无需重启设备，是否整合？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        echo "操作取消！"
        return
    fi
    echo "↴"
    echo "正在检测当前状态..."
    for i in 1
    do
        sleep 1
    done
    VARIAB_PATH="$SURFING_PATH/variab"
    TEMP_PATH="/data/local/tmp/Surfing_variab_backup"
    if [ -d "$GXSURFING_PATH" ]; then
        echo "检测到 安装/更新 Surfing 模块，进行整合..."
        rm -rf "$SURFING_PATH"
        mv "$GXSURFING_PATH" /data/adb/modules/
        if [ -f "$SURFING_PATH/update" ]; then
            rm -f "$SURFING_PATH/update"
        fi    
        echo "整合成功✓"
    else
        echo "没有检测到 安装/更新 Surfing 模块。"
    fi
}
clear_cache() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    ensure_var_path
    CACHE_CLEAR_TIMESTAMP="${VAR_PATH}last_cache_update" 
    if [ -f "$CACHE_CLEAR_TIMESTAMP" ]; then
        last_clear=$(date -d "@$(cat $CACHE_CLEAR_TIMESTAMP)" +"%Y-%m-%d %H:%M:%S")
        echo "距离上次清空缓存是: $last_clear" 
    fi
    echo "此操作会清空数据库缓存，是否清除？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
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
    echo "ok"
    date +%s > "$CACHE_CLEAR_TIMESTAMP"
}
update_geo_database() {
    if [ "$NO_UPDATE_ENABLED" = "true" ]; then
        echo "↴"
        echo "当前是禁用状态，不允许执行该选项！"
        return
    fi
    
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"  
    ensure_var_path
    GEO_DATABASE_VERSION_FILE="${VAR_PATH}geo_database_update"
    if [ -f "$GEO_DATABASE_VERSION_FILE" ]; then
        last_version=$(cat "$GEO_DATABASE_VERSION_FILE")
        echo "距离上次更新的版本号是: $last_version"
    fi
    echo "正在获取服务器中..."
    geo_release=$(curl -s "$GEODATA_URL")
    geo_version=$(echo "$geo_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$geo_version" ]; then
        echo "获取服务器失败！"
        echo "错误：API 速率受限 / 网络异常 ！"
        return
    fi       
    echo "获取成功！"
    echo "当前最新版本号: $geo_version"
    
    if [ "$last_version" = "$geo_version" ]; then
        echo "当前已是最新版本！"
        return
    fi
    echo "是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
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
    echo "正在下载文件中..."
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
    if [ $? -ne 0 ]; then
        echo "设置文件权限失败！"
        return
    fi
    echo "$geo_version" > "$GEO_DATABASE_VERSION_FILE"
}
update_rules() {
    if [ "$NO_UPDATE_ENABLED" = "true" ]; then
        echo "↴"
        echo "当前是禁用状态，不允许执行该选项！"
        return
    fi
    
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    ensure_var_path
    RULES_UPDATE_TIMESTAMP="${VAR_PATH}last_rules_update"    
    if [ -f "$RULES_UPDATE_TIMESTAMP" ]; then
        last_update=$(date -d "@$(cat $RULES_UPDATE_TIMESTAMP)" +"%Y-%m-%d %H:%M:%S")
        echo "距离上次更新是: $last_update"
    fi
    echo "此操作会从 GitHub 拉取最新全部规则，是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ];then
        echo "↴"
        echo "操作取消！"
        return
    fi
    if [ ! -d "$RULES_PATH" ];then

        mkdir -p "$RULES_PATH"
        if [ $? -ne 0 ];then
            echo "创建规则目录失败，请检查权限！"
            return
        fi
    fi
    echo "↴"
    echo "正在下载文件中..."
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
        echo "3. HTTPS Gui Zash"
        echo "4. 本地端口 >>> 127.0.0.1:9090/ui"
        echo "5. 返回上一级菜单"
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
                am start -a android.intent.action.VIEW -d "https://yacd.mereith.com/"
                echo "ok"
                echo ""
                ;;
            3)
                echo "↴"
                echo "正在跳转到 Gui Zash..."
                am start -a android.intent.action.VIEW -d "https://board.zash.run.place/"
                echo "ok"
                echo ""
                ;;
            4)
                echo "↴"
                echo "正在跳转到本地端口..."
                am start -a android.intent.action.VIEW -d "http://127.0.0.1:9090/ui/#/"
                echo "ok"
                echo ""
                ;;
            5)
                echo "↴"
                return
                ;;
            *)
                echo "↴"
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
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    ensure_var_path
    WEB_PANEL_TIMESTAMP="${VAR_PATH}last_web_panel_update"
    last_meta_version=""
    last_yacd_version=""
    last_zash_version=""
    if [ -f "$WEB_PANEL_TIMESTAMP" ]; then
        last_update=$(cat "$WEB_PANEL_TIMESTAMP")
        last_meta_version=$(echo $last_update | cut -d ' ' -f 1)
        last_yacd_version=$(echo $last_update | cut -d ' ' -f 2)
        last_zash_version=$(echo $last_update | cut -d ' ' -f 3)
        echo "距离上次更新的 Meta 版本号是: $last_meta_version"
        echo "距离上次更新的 Yacd 版本号是: $last_yacd_version"
        echo "距离上次更新的 Zash 版本号是: $last_zash_version"
    fi
    echo "正在获取服务器中..."
    meta_release=$(curl -s "$METAA_URL")
    meta_version=$(echo "$meta_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    yacd_release=$(curl -s "$YACDD_URL")
    yacd_version=$(echo "$yacd_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    zash_release=$(curl -s "$ZASHD_URL")
    zash_version=$(echo "$zash_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$meta_version" ] || [ -z "$yacd_version" ] || [ -z "$zash_version" ]; then
        echo "获取服务器失败！"
        echo "错误：API 速率受限 / 网络异常 ！"
        return
    fi  
    echo "获取成功！"   
    echo "Meta 当前最新版本号: $meta_version"
    echo "Yacd 当前最新版本号: $yacd_version"
    echo "Zash 当前最新版本号: $zash_version"

    meta_update_needed=false
    yacd_update_needed=false
    zash_update_needed=false

    if [ "$last_meta_version" != "$meta_version" ]; then
        meta_update_needed=true
    fi

    if [ "$last_yacd_version" != "$yacd_version" ]; then
        yacd_update_needed=true
    fi

    if [ "$last_zash_version" != "$zash_version" ]; then
        zash_update_needed=true
    fi

    if [ "$meta_update_needed" = false ] && [ "$yacd_update_needed" = false ] && [ "$zash_update_needed" = false ]; then
        echo "当前已是最新版本！"
        return
    fi

    echo "是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        echo "操作取消！"
        return
    fi    
    
    if [ "$meta_update_needed" = true ]; then
        echo "↴"
        echo "正在更新：Meta"
        new_install=false
        if [ ! -d "$META_DIR" ]; then
            echo "面板不存在，正在自动安装..."
            mkdir -p "$META_DIR"
            if [ $? -ne 0 ]; then
                echo "创建失败，请检查权限！"
                return
            fi
            new_install=true
        fi
        echo "正在拉取最新的代码..."
        curl -sS -L -o "$TEMP_FILE" "$META_URL"
        if [ $? -eq 0 ]; then
            echo "下载成功，正在效验文件..."
            if [ -s "$TEMP_FILE" ]; then
                echo "文件有效，开始进行$([ "$new_install" = true ] && echo "安装" || echo "更新")..."
                unzip -qo "$TEMP_FILE" -d "$TEMP_DIR"
                if [ $? -eq 0 ]; then
                    rm -rf "${META_DIR:?}"/*
                    if [ $? -ne 0 ]; then
                        echo "操作失败，请检查权限！"
                        return
                    fi
                    mv "$TEMP_DIR/metacubexd-gh-pages/"* "$META_DIR"
                    rm -rf "$TEMP_FILE" "$TEMP_DIR"
                    echo "$([ "$new_install" = true ] && echo "安装成功✓" || echo "更新成功✓")"
                    echo ""
                else
                    echo "解压失败，文件异常！"
                fi
            else
                echo "下载的文件为空或无效！"
            fi
        else
            echo "拉取下载失败！"
        fi   
    fi
    
    if [ "$yacd_update_needed" = true ]; then
        echo "↴"
        echo "正在更新：Yacd"
        new_install=false
        if [ ! -d "$YACD_DIR" ]; then
            echo "面板不存在，正在自动安装..."
            mkdir -p "$YACD_DIR"
            if [ $? -ne 0 ]; then
                echo "创建失败，请检查权限！"
                return
            fi
            new_install=true
        fi
        echo "正在拉取最新的面板代码..."
        curl -sS -L -o "$TEMP_FILE" "$YACD_URL"
        if [ $? -eq 0 ]; then
            echo "下载成功，正在效验文件..."
            if [ -s "$TEMP_FILE" ]; then
                echo "文件有效，开始进行$([ "$new_install" = true ] && echo "安装" || echo "更新")..."
                unzip -qo "$TEMP_FILE" -d "$TEMP_DIR"
                if [ $? -eq 0 ]; then
                    rm -rf "${YACD_DIR:?}"/*
                    if [ $? -ne 0 ]; then
                        echo "操作失败，请检查权限！"
                        return
                    fi
                    mv "$TEMP_DIR/Yacd-meta-gh-pages/"* "$YACD_DIR"
                    rm -rf "$TEMP_FILE" "$TEMP_DIR"
                    echo "$([ "$new_install" = true ] && echo "安装成功✓" || echo "更新成功✓")"
                    echo ""
                else
                    echo "解压失败，文件异常！"
                fi
            else
                echo "下载的文件为空或无效！"
            fi
        else
            echo "拉取下载失败！"
        fi 
    fi 
    
    if [ "$zash_update_needed" = true ]; then
        echo "↴"
        echo "正在更新：Zash"
        new_install=false
        if [ ! -d "$ZASH_DIR" ]; then
            echo "面板不存在，正在自动安装..."
            mkdir -p "$ZASH_DIR"
            if [ $? -ne 0 ]; then
                echo "创建失败，请检查权限！"
                return
            fi
            new_install=true
        fi
        echo "正在拉取最新的代码..."
        curl -sS -L -o "$TEMP_FILE" "$ZASH_URL"
        if [ $? -eq 0 ]; then
            echo "下载成功，正在效验文件..."
            if [ -s "$TEMP_FILE" ]; then
                echo "文件有效，开始进行$([ "$new_install" = true ] && echo "安装" || echo "更新")..."
                unzip -qo "$TEMP_FILE" -d "$TEMP_DIR"
                if [ $? -eq 0 ]; then
                    rm -rf "${ZASH_DIR:?}"/*
                    if [ $? -ne 0 ]; then
                        echo "操作失败，请检查权限！"
                        return
                    fi
                    mv "$TEMP_DIR/dist/"* "$ZASH_DIR"
                    rm -rf "$TEMP_FILE" "$TEMP_DIR"
                    echo "$([ "$new_install" = true ] && echo "安装成功✓" || echo "更新成功✓")"
                else
                    echo "解压失败，文件异常！"
                fi
            else
                echo "下载的文件为空或无效！"
            fi
        else
            echo "拉取下载失败！"
        fi 
    fi
    
    chown -R root:net_admin "$PANEL_DIR"
    find "$PANEL_DIR" -type d -exec chmod 0755 {} \;
    find "$PANEL_DIR" -type f -exec chmod 0666 {} \;
    if [ $? -ne 0 ]; then
        echo "设置文件权限失败！"
        return
    fi
    echo "$meta_version $yacd_version $zash_version" > "$WEB_PANEL_TIMESTAMP"
}
reload_configuration() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    if [ -f "/data/adb/modules/Surfing/disable" ]; then
        echo "↴" 
        echo "服务未运行，重载操作失败！"
        return
    fi
    echo "↴"
    echo "正在重载 Clash 配置..."
    curl -X PUT "$CLASH_RELOAD_URL" -d "{\"path\":\"$CLASH_RELOAD_PATH\"}"
    if [ $? -eq 0 ]; then
        echo "ok"
    else
        echo "重载失败！"
    fi
}
update_core() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    ensure_var_path
    CORE_TIMESTAMP="${VAR_PATH}last_core_update"
    if [ -f "$CORE_TIMESTAMP" ]; then
        last_update=$(cat "$CORE_TIMESTAMP")
        echo "距离上次更新的版本号是: $last_update"
    else
        last_update=""
    fi
    echo "正在获取服务器中..."
    latest_release=$(curl -s "$BASE_URL")
    latest_version=$(echo "$latest_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$latest_version" ]; then
        echo "获取服务器失败！"
        echo "错误：API 速率受限 / 网络异常 ！"
        return
    fi
    download_url="${BASEE_URL}${latest_version}/${RELEASE_PATH}-${latest_version}.gz"
    echo "获取成功！"
    echo "当前最新版本号: $latest_version"
    
    if [ "$last_update" = "$latest_version" ]; then
        echo "当前已是最新版本！"
        return
    fi
    echo "是否更新？回复y/n"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        echo "操作取消！"
        return
    fi
    echo "↴"
    echo "正在下载文件中..."
    curl -sS -L -o "$TEMP_FILE" "$download_url"
    if [ $? -ne 0 ]; then
        echo "下载失败，请检查网络连接是否能正常访问 GitHub！"
        exit 1
    fi
    file_size=$(stat -c%s "$TEMP_FILE")
    if [ "$file_size" -le 100 ]; then
        echo "下载的文件大小异常，停止更新！"
        exit 1
    fi
    echo "文件效验通过，开始进行更新..."
    mkdir -p "$TEMP_DIR"
    gunzip -c "$TEMP_FILE" > "$TEMP_DIR/clash"
    if [ $? -ne 0 ]; then
        echo "解压失败，文件异常！"
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
    echo "ok"
    echo "$latest_version" > "$CORE_TIMESTAMP"
}
open_project_page() {
    echo "↴" 
    echo "正在打开项目地址..."
    if command -v xdg-open > /dev/null; then
        xdg-open "https://github.com/MoGuangYu/Surfing"
    elif command -v am > /dev/null; then
        am start -a android.intent.action.VIEW -d "https://github.com/MoGuangYu/Surfing"
    echo "ok" 
    else
        echo "无法打开浏览器，请手动访问以下地址："
        echo "https://github.com/MoGuangYu/Surfing"
    fi
}
show_menu
