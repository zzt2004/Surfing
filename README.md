# Surfing

<h1 align="center">
  <img src="./folder/Logo.png" alt="CLASHMETA" width="200">
  <br>CLASHMETA<br>
</h1>

<h3 align="center">Magisk, Kernelsu, APatch</h3>

<div align="center">
    <a href="https://github.com/MoGuangYu/Surfing/releases/tag/Prerelease-Alpha">
        <img alt="Android" src="https://img.shields.io/badge/Module Latestsnapshot-F05033.svg?logo=android&logoColor=white">
    </a>
    <a href="https://github.com/MoGuangYu/Surfing/releases/tag/v6.8.12">
        <img alt="Downloads" src="https://img.shields.io/github/downloads/MoGuangYu/Surfing/v6.8.12/total?label=Download@v6.8.12&labelColor=00b56a&logo=git&logoColor=white">
    </a>
</div>

#

**English** | [简体中文](./README_CN.md)

This project is a [Magisk](https://github.com/topjohnwu/Magisk), [Kernelsu](https://github.com/tiann/KernelSU), [APatch](https://github.com/bmax121/APatch) module for Clash, sing-box, v2ray, xray, hysteria. It supports REDIRECT (TCP only), TPROXY (TCP + UDP) transparent proxy, TUN (TCP + UDP), and hybrid mode REDIRECT (TCP) + TUN (UDP) proxy.

Based on upstream integration for one-stop service, ready to use. Suitable for:
- Lazy people
- Beginners

The project's theme and configuration focus on [Clash.Meta](https://github.com/MetaCubeX/Clash.Meta).

This module needs to be used in a Magisk/Kernelsu environment. If you don't know how to configure the required environment, you might need applications like ClashForAndroid, v2rayNG, surfboard, SagerNet, AnXray.

# Surfing User Declaration and Disclaimer

Welcome to use Surfing. Before using this project, please carefully read and understand the following statements and disclaimers. By using this project, you agree to accept the following terms and conditions. Hereinafter referred to as **Surfing**.

## Disclaimer

1. **This project is an open-source project for learning and research purposes only and does not provide any form of guarantee. Users must bear full responsibility for the risks and consequences of using this project.**

2. **This project is only for the convenience of simplifying the installation and configuration of Surfing for Clash services in the Android Magisk environment. It does not make any guarantees about the functionality and performance of Surfing. The developer of this project is not responsible for any problems or losses.**

3. **The use of this projects Surfing module may violate the laws and regulations of your region or the terms of service of service providers. You need to bear the risks of using this project on your own. The developer of this project is not responsible for your actions or the consequences of use.**

4. **The developer of this project is not responsible for any direct or indirect losses or damages resulting from the use of this project, including but not limited to data loss, device damage, service interruption, personal privacy leaks, etc.**

## Instructions for Use

1. **Before using the Surfing module, please make sure you have carefully read and understood the usage instructions and related documents of Clash and Magisk and comply with their rules and terms.**

2. **Before using this project, back up your device data and related settings to prevent unexpected situations. The developer of this project is not responsible for your data loss or damage.**

3. **Please comply with local laws and regulations and respect the legitimate rights and interests of other users when using this project. It is forbidden to use this project for illegal, abusive, or infringing activities.**

4. **If you encounter any problems or have any suggestions when using this project, you are welcome to provide feedback to the developer of this project, but the developer is not obligated to resolve issues or respond to feedback.**

Please decide whether to use the Surfing module only after clearly understanding and accepting the above statements and disclaimers. If you do not agree or cannot accept the above terms, please stop using this project immediately.

## Applicable Law

**During the use of this project, you must comply with the laws and regulations of your region. In case of any disputes, interpretation and resolution should be carried out in accordance with local laws and regulations.**

## Installation

- Download the module zip file from the [Release](https://github.com/MoGuangYu/Surfing/releases) page and install it via Magisk Manager, KernelSU Manager, or APatch.
- Version changes: [📲log](changelog.md)

## Uninstallation

- Uninstall the module from the Magisk Manager, Kernelsu Manager, or APatch application. [👉🏻Removal Command](https://github.com/MoGuangYu/Surfing/blob/main/uninstall.sh#L3-L4)

## Wiki

<details>
<summary>1. First Use</summary>

- After installing the module, you don't need to restart the device. You can use the `Toolbox` integration to refresh the update status of the client
- Add the subscription address in `config.yaml` and reload the configuration.
- Due to network reasons, all rules may not be downloaded automatically. Please manually update/download the rule files.
  - If the above fails, ensure your network environment is normal.
- Web App: [Download](https://github.com/MoGuangYu/Surfing/raw/main/folder/Web_v5.5_release.apk) | [View Source Code](./folder/main.lua)
  - This is a graphical auxiliary tool for convenient browsing and managing backend routing data, with no additional purposes.

> The module has a built-in GUI that can be accessed locally via a browser or used online with the app, with no essential difference between the two.

</details>

<details>
<summary>2. Control Operation</summary>

- You can control the operation service in real time by toggling the module on/off.

</details>

<details>
<summary>3. Geo Database</summary>

GitHub Actions automatically build daily at 6 AM Beijing time, ensuring the latest rules. [Wiki](https://github.com/MetaCubeX/meta-rules-dat)

> Used for routing rule matching to achieve accurate diversion. Updates will always point to the latest version, so you only need to update the file once a month.

</details>

<details>
<summary>4. Subsequent Updates</summary>

- If you use all default configurations, the updates will be seamless
- Supports online module updates within the client, no reboot required after updates; however, module switch control for enabling/disabling will ~~temporarily fail~~, still requiring a reboot. It is recommended to use Toolbox for updates
- During the update, the Clash.Meta config.yaml file will be backed up to
   - `/data/adb/box_bll/clash/config.yaml.bak`
- During the update, old user configuration files will be backed up to
   - `/data/adb/box_bll/scripts/box.config.bak`
- The following are not included in module updates:
   - Geo database files
   - Bin files
   - Web resources

> Ps: Mainly follows upstream updates and distributes some configurations

</details>

<details>
<summary>5. Usage Issues</summary>

1. Proxy Specific Applications (Black/Whitelist)
- To proxy all applications except certain ones, open the `/data/adb/box_bll/scripts/box.config` file, set the `proxy_mode` value to `blacklist` (default), and add elements to the `user_packages_list` array. The format for elements is `id:package_name`, separated by spaces. For example, `user_packages_list=("id:package_name" "id:package_name")` to **not proxy** specific Android user applications.

- To only proxy specific applications, open the `/data/adb/box_bll/scripts/box.config` file, set the `proxy_mode` value to `whitelist`, and add elements to the `user_packages_list` array. The format for elements is `id:package_name`, separated by spaces. For example, `user_packages_list=("id:package_name" "id:package_name")` to **only proxy** specific Android user applications.

Android user group ID identifiers:

| Standard User | ID  |
| ------------- | --- |
| Owner         |  0  |
| Second Space  |  10 |
| App Clone     | 999 |

> Typically, you can find all user group IDs and application package names in `/data/user/`. Do not use fake-ip mode when using black/whitelist.

2. Tun Mode
- Enabled by default

> Recommended to enable under WiFi. If not necessary, it can be disabled. Do not use black/whitelist before enabling this mode.

3. Routing Rules
- Bypass mainland China
- The rules are maintained by the developer and can satisfy most usage needs.

> Black/whitelist is not significant unless strictly required. The module's built-in configuration is sufficient.

4. Panel Management
- Magisk Font Module

> May affect normal display of page fonts.

5. LAN Sharing
- Enable hotspot to allow other devices to connect.

> For other devices to access the console backend, just use (http://currentWiFigateway:9090/ui).

</details>

---

<a href="./LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/MoGuangYu/Surfing.svg">
</a>

## Acknowledgments

<a href="https://github.com/CHIZI-0618">
  <p align="center">
    <img src="https://github.com/CHIZI-0618.png" width="100" height="100" alt="CHIZI-0618">
    <br>
    <strong>CHIZI-0618</strong>
  </p>
</a>

<div align="center">
  <a href="https://github.com/MetaCubeX"><strong>MetaCubeX</strong></a>
</div>

<div align="center">
  <a href="https://github.com/Loyalsoldier"><strong>Loyalsoldier</strong></a>
</div>
<div align="center">
  <p> > Thanks for providing valuable foundation for the implementation of this project. < </p>
</div>
