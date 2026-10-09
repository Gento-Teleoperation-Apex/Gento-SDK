# TJHand SDK 导入说明

## 来源和分支

- 来源：`~/gento_sdk_0826_with_TJHand/gento_sdk_0826`。
- 分支：`update/sdk-4.7.0-tjhand-0826`。
- 基础提交：`e822ccf`，即 `update/sdk-4.7.0`。
- 目标目录：`SDK_CT040700_SDK040700_260824/SDK/00040700`。
- 来源版本宏为 `4.7.0`，不是 `4.7.1`；0826 为来源目录标识。
- 目标沿用基础分支的目录名，目录中的 260824 不是本次导入日期。

共导入 187 个来源文件，排除 Python 缓存。来源未提供的 195 个
`C_HTML` 文档文件沿用基础分支版本；控制器包也沿用基础分支版本。
本次导入保持来源代码和二进制内容，未修改供应方编译脚本或手控制逻辑。

## 与仓库 4.7.0 的比较

| 项目 | 文件数 | 说明 |
| --- | ---: | --- |
| 新增 | 25 | 全部位于 `TJHandInterface`，包含 C/Python 接口、示例、脚本和库 |
| 文本内容改变 | 13 | 控制代码、Python 封装、示例和 UI |
| 二进制改变 | 8 | SDK 库、ARM 库和 FXPlatform |
| 仅换行符差异 | 23 | 配置和文本文件；Git 会按来源 `.gitattributes` 规范化 |
| 完全相同 | 118 | 来源与基础分支按字节比较相同 |

主要代码差异：

- `TJHandInterface/TJHand.h`、`TJHand.cpp` 提供手指位置控制、使能、
  错误清除及位置、电流、温度等反馈读取。
- `TJHandInterface/GentoRobot.py` 增加对应 Python 接口。
  `PYTHON_SDK/GentoRobot.py` 仍是普通封装，二者不能直接视为相同文件。
- `RobotCtrl.cpp` 改用原子交换获取发送锁，并修正序列号缓冲区处理。
- `Utility.cpp` 调整读写锁处理；`Utility.h` 改变 `NC_BUF.m_STag` 的类型。
- `L1Robot.cpp` 增加 `.ota` 文件处理，修正 PD 周期上限处理。
- `FXInterf.cpp` 增加干涉距离查询失败检查。
- `SampleOffsetTable.h` 更新机器人和 AGV 的 IMU 字段。
- 部分 Python 运动示例和 FXPlatform UI 有调整。

## 与仓库 4.7.1 的比较

按相对路径、排除缓存，来源比 `99da61c` 的 SDK 新增 26 个文件，
36 个文件按字节不同，缺少 198 个文件，其中 195 个为 `C_HTML` 文档。
另外缺少两个 C 示例和一个 Python 干涉检查示例。

这不是在 4.7.1 上单纯增加手接口：来源缺少 4.7.1 的部分 SDO 接口、
干涉检查配置接口、手类型查询以及部分反馈字段，干涉接口也存在名称差异。
因此本分支从 4.7.0 建立，4.7.1 分支保持原有内容。

## 验证结果和构建问题

- 导入后，187 个文件均与来源逐字节一致。
- 全部 `.sh` 文件通过 `bash -n` 语法检查。
- 两个 `GentoRobot.py` 封装和新增 TJHand Python 示例通过 Python 3.10
  语法检查。14 个普通 Python 示例的 f-string 使用内外相同引号，
  在当前 Python 3.10 下不能解析，需兼容性修改或较新的 Python。
- 未执行连接机器人、手指运动或使能操作，未完成实际硬件验证。

供应方脚本和库存在以下适配问题：

1. `TJHandInterface/linux_auto_compile.sh` 将 `C_SDK`、`PYTHON_SDK`
   和 `C_EXAMPLE_USE_DLL_SO` 当成本目录子目录，实际它们位于上一级。
2. `TJ_HAND_1/lib/libTJHandLogic.a` 的对象格式为 Windows PE x86-64，
   不能作为 Linux 原生静态库使用。来源另提供 Linux x86-64 `.so`
   和 AArch64 静态库，但没有 Linux x86-64 静态库或协议库源码。
3. 加手交叉编译脚本尝试编译未提供的
   `TJ_HAND_1/src/TJHand_Logic.cpp`，且 SDK 编译命令没有追加 `TJHand.cpp`。
4. 来源 `C_EXAMPLE_USE_DLL_SO/libGentoSDK.so` 未导出 `sendData`、
   `motorEnable`、`getAllHandData` 等 TJHand 封装符号，不能直接当作
   已验证的 Linux 加手 SDK 使用。
5. 现有 Debian 打包入口仍调用 SDK 根目录的普通编译脚本，
   不包含 TJHand 源码，也不会安装 TJHand 头文件和协议库。

本次完成来源导入和内容比较；Linux 加手编译、Python 封装分发、
Debian 打包及硬件联调需继续适配，不能据此宣称加手运行功能已验证。
