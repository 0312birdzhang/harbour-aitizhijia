# 在 Windows/WSL 中打包 SailfishOS RPM

可复用脚本位于 `tools/sailfish-wsl-build.sh`。它在 Windows Git Bash 中运行，依次完成：

1. 使用 `rsync` 将 Windows 项目同步到 WSL 的独立构建目录；
2. 以 root 进入 Sailfish SDK chroot，并以普通 SDK 用户执行 `mb2 build`；
3. 将生成的 RPM 复制回 Windows 项目的 `RPMS` 目录。

## 前置条件

- Windows 已安装 WSL，默认发行版名称为 `Ubuntu-22.04`；
- WSL 内已安装 `rsync`；
- Sailfish SDK 位于 `/srv/sailfishos/sdks/sfossdk`；
- SDK 用户具有 `~/.hadk.env`，且其中可用 `mb2`；
- 项目包含可由 `mb2 build` 使用的 RPM spec 和 qmake/CMake 工程。

## 使用

将 `tools/sailfish-wsl-build.sh` 复制到另一个项目的 `tools` 目录，然后在 Windows Git Bash 中执行：

```bash
./tools/sailfish-wsl-build.sh
```

也可以从任意位置指定项目目录：

```bash
./tools/sailfish-wsl-build.sh 'D:/code/another-sailfish-project'
```

不同设备或 SDK target 可通过环境变量覆盖：

```bash
WSL_DIST=Ubuntu-24.04 \
SDK_USER=builder \
SFOS_TARGET=SailfishOS-latest-armv7hl \
./tools/sailfish-wsl-build.sh 'D:/code/another-project'
```

常用变量可通过 `./tools/sailfish-wsl-build.sh --help` 查看。脚本的 WSL 暂存目录默认限制在
`/home/<SDK_USER>/code/<项目名>`，因为同步过程使用了 `rsync --delete`，不要将该目录指向源码或其他重要目录。

