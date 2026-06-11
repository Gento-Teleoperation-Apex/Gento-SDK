# Gento SDK

## Debian 包使用说明

本仓库会提供 `gento-sdk_*.deb` 安装包，安装后默认文件位置如下：

```text
/usr/local/include/gentosdk
/usr/local/lib/libGentoSDK.so
/usr/local/bin/gento-sdk-version
```

## 1. 获取匹配系统与架构的 deb

从仓库 Release 或构建产物中下载与你环境匹配的包（例如 Ubuntu 22.04 + amd64）。

## 2. 安装 deb

```bash
sudo apt install ./gento-sdk_4.4.0_amd64.deb
```

如果本机缺少依赖，可先执行：

```bash
sudo apt update
sudo apt -f install
```

## 3. 验证安装

```bash
gento-sdk-version
```

若命令正常输出版本号，表示安装成功。

## 4. 在 CMake/colcon 中使用

默认安装前缀是 `/usr/local`，常见用法：

```bash
GENTO_SDK_ROOT=/usr/local colcon build --packages-select <your_package>
```

## 5. 卸载

```bash
sudo apt remove gento-sdk
```
