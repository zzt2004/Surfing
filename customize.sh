#!/sbin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

if [ "$BOOTMODE" ! = true ] ; then
  abort "Error: 请在 Magisk Manager / KernelSU Manager / APatch 中安装"
elif [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ] ; then
  abort "Error: 请更新您的 KernelSU Manager 版本"
fi

if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10683 ] ; then
  service_dir="/data/adb/ksu/service.d"
else 
  service_dir="/data/adb/service.d"
fi

if [ ! -d "$service_dir" ] ; then
    mkdir -p $service_dir
fi

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH
if [ -d /data/adb/box_bll ] ; then
  cp /data/adb/box_bll/clash/config.yaml /data/adb/box_bll/clash/config.yaml.bak
  cp /data/adb/box_bll/scripts/box.config /data/adb/box_bll/scripts/box.config.bak
  
  rm -rf "/data/adb/box_bll/clash/Gui Yacd: 获取面板.sh"
  rm -rf "/data/adb/box_bll/clash/Gui Meta: 获取面板.sh"
  rm -rf "/data/adb/box_bll/clash/Telegram chat.sh"
  rm -rf "/data/adb/box_bll/clash/country.mmdb"
  rm -rf "/data/adb/box_bll/clash/UpdateGeo.sh"
  rm -rf "/data/adb/box_bll/clash/ASN.mmdb"
  rm -rf "/data/adb/box_bll/clash/Update: 数据库.sh"
  rm -rf "/data/adb/box_bll/clash/Telegram: 聊天组.sh"
  rm -rf "/data/adb/box_bll/clash/Gui Meta: 在线面板.sh"
  rm -rf "/data/adb/box_bll/clash/Gui Yacd: 在线面板.sh"
  rm -rf /data/adb/box_bll/clash/dashboard
  
  cp -f $MODPATH/box_bll/clash/config.yaml /data/adb/box_bll/clash/
  cp -f $MODPATH/box_bll/clash/enhanced_config.yaml /data/adb/box_bll/clash/
  cp -f $MODPATH/box_bll/clash.Toolbox.sh /data/adb/box_bll/clash/
  cp -f $MODPATH/box_bll/scripts/* /data/adb/box_bll/scripts/
  rm -rf $MODPATH/box_bll

  ui_print "- Updating..."
  ui_print "- ————————————————"
  ui_print "- 配置文件 config.yaml 已备份 bak："
  ui_print "- 如更新订阅需重新添加订阅链接！"
  ui_print "- ————————————————"
  ui_print "- 用户配置 box.config 已备份 bak："
  ui_print "- 可自行选择重新配置或使用默认！"
  ui_print "- ————————————————"
  ui_print "- 正在等待重启中..."
else
  mv $MODPATH/box_bll /data/adb/
  ui_print "- Installing..."
  ui_print "- ————————————————"
  ui_print "- 安装完成 工作目录"
  ui_print "- data/adb/box_bll/"
  ui_print "- ————————————————"
  ui_print "- 正在等待重启中..."
fi

if [ "$KSU" = true ] ; then
  sed -i 's/name=Surfingmagisk/name=SurfingKernelSU/g' $MODPATH/module.prop
fi

if [ "$APATCH" = true ] ; then
  sed -i 's/name=Surfingmagisk/name=SurfingAPatch/g' $MODPATH/module.prop
fi

mkdir -p /data/adb/box_bll/bin/
mkdir -p /data/adb/box_bll/run/

mv -f $MODPATH/Surfing_service.sh $service_dir/

rm -f customize.sh

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive /data/adb/box_bll/ 0 0 0755 0644
set_perm_recursive /data/adb/box_bll/clash/log/ 0 0 0777 0666
set_perm_recursive /data/adb/box_bll/run/ 0 0 0755 0666
set_perm_recursive /data/adb/box_bll/clash/proxy_providers/ 0 0 0755 0666
set_perm_recursive /data/adb/box_bll/clash/rule/ 0 0 0755 0666
set_perm_recursive /data/adb/box_bll/scripts/ 0 0 0755 0700
set_perm_recursive /data/adb/box_bll/bin/ 0 0 0755 0700

set_perm $service_dir/Surfing_service.sh 0 0 0700

chmod ugo+x /data/adb/box_bll/scripts/*

for pid in $(pidof inotifyd) ; do
  if grep -q box.inotify /proc/${pid}/cmdline ; then
    kill ${pid}
  fi
done

inotifyd "/data/adb/box_ll/scripts/box.inotify" "$MODPATH" > /dev/null 2>&1 &
