require "luajava"
require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.content.Intent"
import "android.net.Uri"
import "android.view.KeyEvent"
import "androidx.appcompat.widget.PopupMenu"
import "androidx.cardview.widget.CardView"
import "android.content.Context"
import "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
import "android.os.Build"
import "android.app.PendingIntent"
import "androidx.core.app.NotificationCompat"
import "android.app.NotificationManager"
import "android.os.Bundle"
import "androidx.appcompat.app.AppCompatActivity"
import "java.lang.String"
import "java.lang.System"
import "android.app.NotificationChannel"
import "com.androlua.Http"
import "androidx.appcompat.app.AlertDialog"
import "android.app.AlertDialog"
import "android.content.SharedPreferences"
import "android.preference.PreferenceManager"
import "android.widget.LinearLayout"
import "android.widget.ScrollView"
import "android.widget.TextView"
import "android.widget.Button"
import "android.widget.Toast"
state = "android"

function onKeyDown(keyCode, event)
  if keyCode == KeyEvent.KEYCODE_BACK then
    return true
  end
  return false
end
url = "https://sharechain.qq.com/0f01a186ca539e8e4e97e48b2d2d529a"
local headers = {["User-Agent"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36"}
Http.get(url .. "#t=" .. os.time(), nil, "UTF-8", headers, function(code, content, cookie, header)
  if (code == 200 and content) then
    content = content:match('<div class="note%-content">(.-)</div>%s+</article>')
    content = content:gsub("</p><p>", "") or content
    content = content:gsub("<%/?p>", "") or content
    content = content:gsub("</div><div>", "") or content
    content = content:gsub("<%/?div>", "") or content
    content = content:gsub("<%/?span>", "") or content
    content = content:gsub("<br%s+/>", "\n") or content
    content = content:gsub("&nbsp;", " ") or content
    content = content:gsub("</div><div>", "") or content
    content = content:gsub("！", "\n") or content
    公告标题 = content:match("【公告标题】(.-)【公告标题】")
    公告内容 = content:match("【公告内容】(.-)【公告内容】")
    按钮标题 = content:match("【按钮标题】(.-)【按钮标题】")
    公告显示 = content:match("【公告显示】(.-)【公告显示】")
    公告返回 = content:match("【公告返回】(.-)【公告返回】")
    暗主题 = content:match("【暗主题】(.-)【暗主题】")
    if (暗主题 == "开") then
      UIColor = "#222222"
      btColor = "#ffffff"
      nrColor = "#dfffffff"
     else
      UIColor = "#ffffff"
      btColor = "#000000"
      nrColor = "#98000000"
    end
    公告布局 = {
      LinearLayout;
      orientation = 'vertical';
      layout_width = 'fill';
      layout_height = 'fill';

      {
        CardView;i
        layout_gravity = 'center';
        layout_width = '80%w';
        layout_height = '36%h';
        cardBackgroundColor = UIColor;
        layout_margin = '0dp';
        cardElevation = '2dp';
        radius = '10dp';
        {
          LinearLayout;
          orientation = 'vertical';
          layout_width = 'fill';
          layout_height = '45dp';
          background = UIColor;
          {
            TextView;
            id = 'bt';
            layout_width = 'fill';
            layout_height = 'fill';
            text = 公告标题;
            textSize = '20sp';
            textColor = btColor;
            gravity = 'bottom|center';
          };
        };
        {
          ScrollView; 
          layout_width = 'fill';
          layout_height = '176dp';
          layout_marginTop = '55dp';
          background = UIColor;
          {
            TextView;
            id = 'nr';
            layout_width = 'fill';
            layout_marginTop = '5dp';
            layout_height = 'wrap_content'; 
            layout_margin = '30dp';
            text = 公告内容;
            textSize = '15sp';
            textColor = nrColor;
            gravity = 'left';
          };
        };
        {
          CardView;
          layout_gravity = 'bottom|center';
          layout_width = '75dp';
          layout_height = '35dp';
          layout_marginBottom = '15dp';
          cardBackgroundColor = '#FF0055FF';
          layout_margin = '0dp';
          cardElevation = '3dp';
          alpha = 0.85;
          radius = '15dp';
          {
            TextView;
            id = 'nn1';
            layout_width = 'fill';
            layout_height = 'fill';
            text = 按钮标题;
            textSize = '15sp';
            textColor = '#ffffff';
            gravity = 'center';
            onClick = function(v)
              tc.dismiss()
            end;
          };
        };
      };
    };

    tc = AlertDialog.Builder(this).show()

    if (公告返回 == "开") then
      tc.setCancelable(true)
     else
      tc.setCancelable(false)
    end

    tc.setCanceledOnTouchOutside(false) 
    tc.getWindow().setContentView(loadlayout(公告布局))
    import "android.graphics.drawable.ColorDrawable"
    tc.getWindow().setBackgroundDrawable(ColorDrawable(0x00000000))
    tc.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM)
    bt.getPaint().setFakeBoldText(true)
    nr.getPaint().setFakeBoldText(true)
    nn1.getPaint().setFakeBoldText(true)

    if (公告显示 == "关") then
      tc.dismiss()
     else
      tc.show()
    end

   else
    print("获取公告失败 " .. code)
  end
end)

Http.get("https://sharechain.qq.com/1de6f359366b75e91ee46050c56d6e5a", nil, nil, nil, function(code, content)
  if code == 200 then
    content = content:gsub("！", "\n") or content
    版本 = content:match("【版本名】(.-)【版本名】")
    更新内容 = content:match("【更新内容】(.-)【更新内容】")
    链接 = content:match("【下载链接】(.-)【下载链接】")
    packinfo = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0)
    本地 = tostring(packinfo.versionName)
    远程 = tostring(版本)
    if 本地 < 远程 then
      更新内容 = 更新内容:gsub("\\n", "\n")
      更新z = AlertDialog.Builder(activity)
      更新z.setTitle("发现新版本：" .. 版本)
      更新z.setMessage(更新内容)
      更新z.setPositiveButton("获取", function(dialog, which)
        local viewIntent = Intent("android.intent.action.VIEW", Uri.parse(链接))
        activity.startActivity(viewIntent)
        activity.finish()
      end)
      更新z.setNegativeButton("取消", function(dialog, which)
      end)
      更新z.setCancelable(false)
      更新z.show()
    end
  end
end)

function checkNetworkConnection()
  local connectivityManager = activity.getSystemService(Context.CONNECTIVITY_SERVICE)
  local networkInfo = connectivityManager.getActiveNetworkInfo()
  if networkInfo and networkInfo.isConnected() then
    return true
   else
    return false
  end
end

function saveDefaultUrl(url)
  local editor = preferences.edit()
  editor.putString("defaultUrl", url)
  editor.apply()
end

function loadDefaultUrl()
  return preferences.getString("defaultUrl", "")
end

if not checkNetworkConnection() then
  local Toast = luajava.bindClass("android.widget.Toast")
  Toast.makeText(activity, "请检查你的网络设置", Toast.LENGTH_SHORT).show()
  activity.finish()
  return
end

--activity.getWindow().setNavigationBarColor(0xCA948AD9)
activity.getWindow().setStatusBarColor(0xFF202020)
--activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR)

local swipeRefreshLayout = SwipeRefreshLayout(activity)

local layout = {
  LinearLayout,
  orientation = "vertical",
  layout_width = "match_parent",
  layout_height = "match_parent",
  gravity = "center",
  backgroundColor = "0xFF202020",
  {
    LinearLayout,
    orientation = "horizontal",
    gravity = "center",
    layout_width = "fill",
    layout_height = "60dp",
    backgroundColor = "0xFF202020",
    {
      CardView,
      layout_margin = "0dp",
      layout_gravity = "center",
      layout_marginLeft = "10dp",
      layout_marginRight = "10dp",
      elevation = "0",
      layout_width = "fill",
      CardBackgroundColor = "0xffffffff",
      layout_height = "45dp",
      radius = "30dp",
      {
        LinearLayout, 
        orientation = "horizontal", 
        gravity = "center",
        layout_width = "fill",
        layout_height = "fill",
        backgroundColor = "",
        {
          ImageView,
          id = "avatar",
          src = "img/face.png",
          layout_width = "25dp",
          layout_height = "25dp",
          layout_marginLeft = "10dp",
          colorFilter = "0xFF000000",
          scaleType = "fitXY",
        },
        {
          EditText,
          id = "ed",
          layout_weight = "1",
          layout_height = "wrap",
          textSize = "15sp",
          hintTextColor = "0xFF000000",
          textColor = "0xff000000",
          Hint = "hello Clash.Meta...",
          imeOptions = "actionSearch",
          singleLine = true,
          enabled = false
        },
        {
          ImageView,
          src = "img/crosshairs_gps.png",
          layout_width = "23dp",
          layout_height = "23dp",
          layout_marginLeft = "10dp",
          colorFilter = "0xff888888",
          scaleType = "fitXY",
          onClick = function()
            webView.loadUrl("https://ip.skk.moe/")
          end
        },
        {
          ImageView, 
          src = "img/speedometer.png", 
          layout_width = "23dp",
          layout_height = "23dp",
          layout_marginLeft = "10dp",
          colorFilter = "0xff888888",
          scaleType = "fitXY",
          onClick = function()
            webView.loadUrl("https://fast.com/zh/cn/")
          end
        },
        {
          ImageView,
          src = "img/refresh.png",
          layout_width = "23dp",
          layout_height = "23dp",
          layout_marginLeft = "10dp",
          colorFilter = "0xff888888",
          scaleType = "fitXY",
          onClick = function()
            webView.reload()
          end
        },
        {
          ImageView,
          id = "more",
          src = "img/ic_more.png",
          layout_width = "25dp",
          layout_height = "fill",
          layout_marginLeft = "10dp",
          layout_marginRight = "10dp",
          colorFilter = "0xff888888",
          scaleType = "centerInside"
        }
      }
    }
  },
  {
    LuaWebView,
    layout_width = "fill",
    layout_height = "fill",
    id = "webView"
  }
}
swipeRefreshLayout.addView(loadlayout(layout))

swipeRefreshLayout.setOnRefreshListener(luajava.createProxy("androidx.swiperefreshlayout.widget.SwipeRefreshLayout$OnRefreshListener", {
  onRefresh = function()
    webView.reload()
    swipeRefreshLayout.setRefreshing(false)
  end
}))

webView.setOnScrollChangeListener(luajava.createProxy("android.view.View$OnScrollChangeListener", {
  onScrollChange = function(v, scrollX, scrollY, oldScrollX, oldScrollY)
    if scrollY == 0 and not swipeRefreshLayout.isRefreshing() then
      swipeRefreshLayout.setEnabled(true)
     else
      swipeRefreshLayout.setEnabled(false)
    end
  end
}))

preferences = activity.getSharedPreferences("settings", Context.MODE_PRIVATE)

local defaultUrl = loadDefaultUrl()

if defaultUrl == "" then
  defaultUrl = "https://yacd.metacubex.one/"
end
--activity.setContentView(swipeRefreshLayout)
activity.setContentView(loadlayout(layout))

webView.loadUrl(defaultUrl)

function saveDefaultUrl(url)
  local editor = preferences.edit()
  editor.putString("defaultUrl", url)
  editor.apply()
end

avatar.onClick = function()
  if defaultUrl ~= "" then
    webView.loadUrl(defaultUrl)
   else
    webView.loadUrl("https://yacd.metacubex.one/")
  end
end

ed.setOnKeyListener({
  onKey=function(v,keyCode,event)
    if (KeyEvent.KEYCODE_ENTER == keyCode and KeyEvent.ACTION_DOWN == event.getAction()) then
      webView.loadUrl("https://www.google.com/search?q="..ed.text)
      return true;
    end
  end
})

more.onClick = function()
  local pop = PopupMenu(activity, more)
  local menu = pop.Menu
  menu.add("清除数据").onMenuItemClick = function(a)
    local builder = AlertDialog.Builder(activity)
    builder.setTitle("注意")
    builder.setMessage("此操作会清除自身全部数据并退出！")
    builder.setPositiveButton("确定", function(dialog, which)
      activity.finish()
      if activity.getPackageName() ~= "net.fusionapp" then
        os.execute("pm clear " .. activity.getPackageName())
      end
    end)
    builder.setNegativeButton("取消", nil)
    builder.setCancelable(false)
    builder.show()
  end

  menu.add("设置URL").onMenuItemClick = function(a)
    local builder = AlertDialog.Builder(activity)
    builder.setTitle("设置URL")
    builder.setMessage("请输入要设置默认访问的链接：")
    local input = EditText(activity)
    input.setHint("http:// https://")
    builder.setView(input)
    builder.setPositiveButton("确定", function(dialog, which)
      local url = input.getText().toString()
      if url ~= "" and string.match(url, "^[%w:%/%.%-%?%=%&]+") then
        defaultUrl = url
        webView.loadUrl(defaultUrl)
        saveDefaultUrl(defaultUrl)
       else
        local errorDialog = AlertDialog.Builder(activity)
        errorDialog.setTitle("错误")
        errorDialog.setMessage("请输入有效的URL链接！")
        errorDialog.setPositiveButton("确定", function(dialog, which)
          -- Do nothing
        end)
        errorDialog.setCancelable(false)
        errorDialog.show()
      end
    end)
    builder.setNegativeButton("取消", nil)
    builder.setCancelable(false)
    builder.show()
  end

  menu.add("版本信息").onMenuItemClick = function(a)
    local builder = AlertDialog.Builder(activity)
    builder.setTitle("当前版本：v5.5")
    builder.setMessage("GUI")
    builder.setNegativeButton("Git", function(dialog, which)
      activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/MoGuangYu/Surfing")))
    end)
    builder.setNeutralButton("取消", nil)
    builder.setCancelable(false)
    builder.show()
  end
  pop.show()
end

webView.loadUrl(defaultUrl)

local lastBackgroundTime = 0
local isInBackground = false

function onPause()
  lastBackgroundTime = os.time()
  isInBackground = true
end

function onResume()
  if isInBackground then
    local currentTime = os.time()
    local backgroundTime = currentTime - lastBackgroundTime

    if backgroundTime >= 120 then
      webView.reload()
    end

    isInBackground = false
    lastBackgroundTime = 0
  end
end

local AGREED_KEY = "agreed_disclaimer"

local preferences = PreferenceManager.getDefaultSharedPreferences(activity)

local agreed = preferences.getBoolean(AGREED_KEY, false)

if not agreed then
  local dialog = AlertDialog.Builder(activity)
  .setCancelable(false)
  .create()

  local layout = {
    LinearLayout;
    orientation = 'vertical';
    padding = '16dp';
    {
      ScrollView;
      layout_width = 'match_parent';
      layout_height = '468dp';
      {
        TextView;
        layout_width = 'match_parent';
        layout_height = 'wrap_content';
        text = [[
在使用之前，请仔细下滑阅读以下免责协议。使用即表示您同意遵守本协议的所有条款和条件。

1. 目的
本程序是基于Clash的便携浏览工具，旨在方便使用查看和管理Clash代理的相关信息。此程序仅供学习研究之用，并无其它用途。

2. 免责声明
本程序仅作为浏览工具提供，不提供任何代理服务。我们不对您通过本程序访问的任何内容的准确性、合法性、安全性或完整性承担任何责任。您在使用本程序时应自行承担风险。

3. 第三方链接
本程序可能包含指向第三方网站或资源的链接，这些链接仅供您参考。我们对这些第三方网站或资源的内容、隐私政策、服务或产品的可用性不承担任何责任。您应自行判断并承担使用这些第三方链接的风险。

4. 法律合规
在使用本程序时，您应遵守适用的法律法规。您对通过本程序访问的任何内容的使用应符合相关法律法规，包括但不限于版权法、隐私法和计算机犯罪法。

5. 修改和终止
我们保留根据需要随时修改或终止本免责协议的权利。任何修改将在本程序上发布并生效。继续使用本程序即表示您接受修改后的免责协议。

请确保在使用本程序之前仔细阅读并理解本免责协议的所有条款和条件。如果您不同意本程序协议的任何部分，请立即卸载停止使用本程序。
    ]];
        padding = '10dp';
      };
    };
    {
      Button;
      layout_width = 'match_parent';
      layout_height = 'wrap_content';
      text = "同意";
      onClick = function()
        local editor = preferences.edit()
        editor.putBoolean(AGREED_KEY, true)
        editor.apply()
        Toast.makeText(activity, "已阅读并同意", Toast.LENGTH_SHORT).show()
        dialog.dismiss()
      end;
    };
    {
      Button;
      layout_width = 'match_parent';
      layout_height = 'wrap_content';
      text = "不同意";
      onClick = function()
        local packageUri = "package:" .. activity.getPackageName()
        local uninstallIntent = Intent(Intent.ACTION_DELETE, Uri.parse(packageUri))
        activity.startActivity(uninstallIntent)
        activity.finish()
      end;
    };
  }

  local layoutContext = ContextThemeWrapper(activity, android.R.style.Theme_Material_Light)
  local contentView = loadlayout(layout, layoutContext)

  dialog.setView(contentView)

  dialog.show()
end

------------
