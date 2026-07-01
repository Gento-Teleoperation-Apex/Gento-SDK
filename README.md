# Gento SDK

## CI 自动打包和发布

GitHub Actions workflow 位于 `.github/workflows/build-sdk-debs.yml`，会为 Ubuntu 20.04、22.04、24.04 生成 `amd64` 和 `arm64` Debian 包。

### 自动发布

推送 `v*` 格式的 tag 会自动构建并发布到对应的 GitHub Release：

```bash
git tag v4.4.2
git push origin v4.4.2
```

### 手动发布

1. 打开 GitHub 仓库页面。
2. 进入 `Actions` -> `Build SDK Debian Packages`。
3. 点击 `Run workflow`。
4. 选择包含最新 workflow 的分支。
5. 填写参数：
   - `publish_release`: 勾选 `true`
   - `release_tag`: 填写要发布的 tag，例如 `v4.4.2`
6. 启动 workflow。

手动运行时，如果没有勾选 `publish_release`，或者没有填写 `release_tag`，`publish` job 会被跳过，只生成 artifact，不上传到 GitHub Release。

### 只生成包不发布

在 `Actions` 页面手动运行 workflow 时，不勾选 `publish_release` 即可。构建完成后，可以在 workflow run 的 artifact 中下载生成的 `.deb` 文件。
