# 此为 **Windows** 平台开箱即用指南  

1. 下载 [zip](https://github.com/MoGuangYu/Surfing/releases/download/v6.9.1/Surfing_v1-windows-amd64.zip) 并解压至桌面。  
2. 在 `mihomo-windows-amd64.exe` 上右键 -> **属性** -> **兼容性**，勾选“以管理员权限运行此程序”  
   - **tips**：Tun 模式需要管理员权限运行。  
3. 编辑 **config.yaml** 填入订阅，使用方法与 **Android** 相同 ，并且检查控制面板**路径**是否正确指向 **Meta** 文件夹
3. 双击 `mihomo.start.vbs` 运行即可。  
4. 控制台地址: 
   ```text
   http://localhost:9090/ui    
   ```
5. 默认密码: 无，可在 **config.yaml** 中的 `secret` 值设置

# 开机自启动

1. 编辑 `Mihomo.Startup.xml` 替换实际脚本路径
2. 打开 **Windows** 任务计划程序
3. 导入 `Mihomo.Startup.xml`，或新建一个任务来开机运行 `mihomo.start.vbs`.
4. 按需修改任务名称、**文件路径**、触发器、条件等等。
5. **在“常规”选项卡中，勾选“使用最高权限运行”**。（如果不设置此选项，每次启动会跳出 UAC 窗口）