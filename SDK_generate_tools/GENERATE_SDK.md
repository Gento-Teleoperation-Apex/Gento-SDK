# generate_sdk.sh 使用说明

`generate_sdk.sh` 用于在 Linux 下自动编译 Gento SDK，并生成可安装的 Debian 包。

默认执行时会完成三件事：

1. 自动查找并运行 `linux_auto_compile.sh`
2. 编译生成 `libGentoSDK.so` 和 `libGentoSDKPY.so`
3. 把 C SDK 头文件、`libGentoSDK.so` 和 `gento-sdk-version` 打成 `.deb`

## 快速使用

在仓库根目录执行：

```bash
./SDK_generate_tools/generate_sdk.sh
```

当前目录结构下，脚本会自动找到：

```text
SDK_CT040500_SDK040500_260709/SDK/00040500/linux_auto_compile.sh
SDK_CT040500_SDK040500_260709/SDK/00040500/C_SDK
```

生成的 deb 默认放在仓库根目录，例如：

```text
gento-sdk_4.5.0_amd64.deb
```

安装：

```bash
sudo apt install ./gento-sdk_4.5.0_amd64.deb
```

安装后验证：

```bash
gento-sdk-version
```

## 依赖

需要系统里有：

```bash
sudo apt install build-essential dpkg-dev
```

其中：

- `g++` 用于编译 SDK 动态库和 `gento-sdk-version`
- `dpkg-deb` 用于生成 `.deb` 包

## 常用参数

### 指定输出目录

```bash
./SDK_generate_tools/generate_sdk.sh --output-dir dist
```

生成结果示例：

```text
dist/gento-sdk_4.5.0_amd64.deb
```

### 跳过自动编译，只打包现有 so

```bash
./SDK_generate_tools/generate_sdk.sh --no-compile
```

适用于已经手动运行过 `linux_auto_compile.sh`，只想重新生成 deb 的情况。

### 指定 SDK 根目录

`--sdk-root` 指向 `C_SDK` 目录：

```bash
./SDK_generate_tools/generate_sdk.sh --sdk-root SDK_CT040500_SDK040500_260709/SDK/00040500/C_SDK
```

### 指定编译脚本

```bash
./SDK_generate_tools/generate_sdk.sh --compile-script SDK_CT040500_SDK040500_260709/SDK/00040500/linux_auto_compile.sh
```

### 指定安装前缀

默认安装到 `/usr/local`：

```text
/usr/local/include/gentosdk
/usr/local/lib/libGentoSDK.so
/usr/local/bin/gento-sdk-version
```

如果希望 deb 安装到其他路径，例如 `/opt/gentosdk`：

```bash
./SDK_generate_tools/generate_sdk.sh --prefix /opt/gentosdk
```

安装后使用 CMake 时可指定：

```bash
GENTO_SDK_ROOT=/opt/gentosdk colcon build --packages-select marvin_ros_control
```

### 指定包名或版本号

```bash
./SDK_generate_tools/generate_sdk.sh --package-name gento-sdk --package-version 00040500
```

如果不指定 `--package-version`，当前脚本会优先从：

```text
C_SDK/Common/FXCommon.h
```

读取：

```c
FX_SDK_MAJOR_VERSION
FX_SDK_MINOR_VERSION
FX_SDK_PATCH_VERSION
```

并生成类似 `4.5.0` 的 deb 版本号。

如果没有读到这些宏，才会从路径里的 SDK 目录名，例如 `SDK/00040500/C_SDK`，取 `00040500` 作为版本号。

## 直接安装模式

除了生成 deb，也可以直接安装到本机：

```bash
./SDK_generate_tools/generate_sdk.sh --install
```

如果默认安装到 `/usr/local`，通常需要 sudo 权限；脚本会在需要时调用 `sudo`。

## 查看已安装版本

```bash
./SDK_generate_tools/generate_sdk.sh --version
```

该命令会调用已安装的：

```text
/usr/local/bin/gento-sdk-version
```

如果还没有安装，会提示先安装。

## 典型流程

```bash
./SDK_generate_tools/generate_sdk.sh
sudo apt install ./gento-sdk_4.5.0_amd64.deb
gento-sdk-version
```

如果需要用 `00040500` 作为 deb 版本号：

```bash
./SDK_generate_tools/generate_sdk.sh --package-version 00040500
sudo apt install ./gento-sdk_00040500_amd64.deb
```

## 多系统多架构构建

如果需要同时生成 Ubuntu 20.04、22.04、24.04 的 `amd64` 和 `arm64` 包，使用：

```bash
./SDK_generate_tools/build_all_debs.sh
```

该脚本通过 Docker 在对应 Ubuntu 容器中编译，输出目录为：

```text
dist/
  ubuntu20.04/
    amd64/*.deb
    arm64/*.deb
  ubuntu22.04/
    amd64/*.deb
    arm64/*.deb
  ubuntu24.04/
    amd64/*.deb
    arm64/*.deb
```

只构建一个目标：

```bash
./SDK_generate_tools/build_all_debs.sh --ubuntu 22.04 --arch arm64
```

在 amd64 机器上构建 arm64 需要 Docker QEMU/binfmt 支持。GitHub Actions 中已经自动配置 QEMU。

## GitHub Actions 自动构建

已提供 workflow：

```text
.github/workflows/build-sdk-debs.yml
```

触发方式：

- 手动运行 `workflow_dispatch`
- 推送 `v*` tag，例如 `v4.5.0`

Actions 会构建 6 个目标：

```text
ubuntu20.04 amd64
ubuntu20.04 arm64
ubuntu22.04 amd64
ubuntu22.04 arm64
ubuntu24.04 amd64
ubuntu24.04 arm64
```

每个目标会作为 GitHub Actions artifact 上传。
