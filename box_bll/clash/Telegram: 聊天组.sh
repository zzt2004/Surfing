#!/system/bin/sh
echo "正在尝试加入群聊，如跳转失败请提前打开 Telegram App..."
echo "脚本即将开始，请稍候..."
for i in $(seq 5 -1 1); do
  echo "time: $i "
  sleep 1
done
am start -a android.intent.action.VIEW -d "https://t.me/+vvlXyWYl6HowMTBl"
echo "操作已完成，请检查您的 Telegram App 是否已成功跳转。"
