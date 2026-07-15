# ❄️ NixOS 實體機落地與主權移交指南 (Calamares 穩健流派)

本文件記載如何透過 NixOS 官方圖形安裝程式（Calamares）完成實體機（AMD CPU/GPU 節點）的地基搭建，並在落地後將系統主權天衣無縫地引渡至本 Flake 配置倉庫中。

---

## 🏎️ 全新實體機落地部署五部曲

當您使用 NixOS Live USB 開機，並透過圖形安裝程式按「下一步」完成初始系統安裝（包含建立使用者與基本磁碟分割）後，請重啟進入新系統，拉開終端機發動以下主權奪取攻勢：

### 1. 物理攔截「肉身晶片指針」

官方安裝程式會在全域路徑留下專屬這台實體機的硬體識別與磁碟掛載帳本，先將其撈出備用：

```bash
cp /etc/nixos/hardware-configuration.nix ~/Downloads/
```

### 2. 引渡大腦：部署配置倉庫至專屬路徑

建立用戶配置中心，並將您在 GitHub 上的通用配置拉回本地：

```bash
mkdir -p ~/.config
git clone https://github.com/jimmywmt/nixos.git ~/.config/nixos
cd ~/.config/nixos
```

### 3. 基因縫合與肉身升級

將剛剛備份的實體肉身塞進倉庫，並手動打造專屬這台電腦的驅動組件：

- 物理覆蓋硬體掛載檔

```bash
cp ~/Downloads/hardware-configuration.nix ./
```

### 4. 建立不同機器設定

在檔案就緒、但還沒 rebuild 之前，立刻建立local.nix檔案。這能確保本地修改滿血通電：

```bash
cp local.nix.example local.nix
```

如果要修改 profiles/gpu-desktop.nix

```bash
git update-index --assume-unchanged profiles/gpu-desktop.nix
```

### 5. 絕殺：主權強行強占 (Flake Rebuild)

發動總攻，抹除官方安裝程式留下的預設環境，用您精心燙平的完全體大腦進行純函數式重構：

```bash
# 請對齊您在 flake.nix 裡設定的主機標籤（例如 nixos）
sudo nixos-rebuild switch --flake ~/.config/nixos/#pve-profile
```
