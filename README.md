# Gento SDK

本分支 `update/sdk-4.7.0-tjhand-0826` 导入了 `gento_sdk_0826_with_TJHand`
提供的 **4.7.0 加手 SDK**，基于 `update/sdk-4.7.0`。
SDK 位于 `SDK_CT040700_SDK040700_260824/SDK/00040700`，
手接口位于其 `TJHandInterface` 子目录。
原始文件已导入；Linux 加手构建和 Debian 打包仍需适配，详见
[来源、差异及验证说明](TJHAND_IMPORT.md)。

## CI 自动打包和发布

GitHub Actions workflow 位于 `.github/workflows/build-sdk-debs.yml`，会为 Ubuntu 20.04、22.04、24.04 生成 `amd64` 和 `arm64` Debian 包。

### 自动发布

推送 `v*` 格式的 tag 会自动构建并发布到对应的 GitHub Release：

```bash
git tag v4.5.0
git push origin v4.5.0
```

### 手动发布

1. 打开 GitHub 仓库页面。
2. 进入 `Actions` -> `Build SDK Debian Packages`。
3. 点击 `Run workflow`。
4. 选择包含最新 workflow 的分支。
5. 填写参数：
   - `publish_release`: 勾选 `true`
   - `release_tag`: 填写要发布的 tag，例如 `v4.5.0`
6. 启动 workflow。

手动运行时，如果没有勾选 `publish_release`，或者没有填写 `release_tag`，`publish` job 会被跳过，只生成 artifact，不上传到 GitHub Release。

### 只生成包不发布

在 `Actions` 页面手动运行 workflow 时，不勾选 `publish_release` 即可。构建完成后，可以在 workflow run 的 artifact 中下载生成的 `.deb` 文件。
