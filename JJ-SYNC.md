# JJ-SYNC.md — NixOS 多機同步機制說明

本倉庫（`~/.config/nixos`）同時管理多台 NixOS 機器：

| 機器 | 顯卡 | 用途 |
|---|---|---|
| `wmt-amd-nixos` | AMD RX 5700 XT | 主力桌面工作站 |
| `wmt-nvidia-nixos` | NVIDIA RTX 5090 | AI/遊戲工作站 |

三台（含 Mac）共用同一個 repo，但各自的**硬體設定彼此不同**，所以需要一套「共享設定同步、機器獨用設定不同步」的機制。本文說明這套機制。

---

## 一、核心概念：兩個層次

| 層次 | 內容 | 放哪裡 | 推 GitHub？ |
|---|---|---|---|
| **共享層** | 所有機器共用的設定（`home.nix`、`configuration.nix`、`packages.nix`、`users.nix`） | repo 根目錄 | ✅ 會推 |
| **機器獨用層** | 只有這台適用的設定（hostname、顯卡驅動、硬碟掛載、獨用 app） | 同名檔案 + `.example` 範本 | ❌ 不推 |

機器獨用層的清單集中在 **`local-files.txt`**，這是「單一事實來源」。

---

## 二、檔案職責劃分

### 共享檔案（會上 GitHub）

| 檔案 | 職責 |
|---|---|
| `flake.nix` | 定義 `gpu-profile` |
| `configuration.nix` | 系統層設定（Sway、服務、套件） |
| `home.nix` | 使用者層設定（zsh、nvim、programs） |
| `packages.nix` | 系統套件與 overlay |
| `users.nix` | 使用者帳號 |
| `modules/local-files.nix` | 機器獨用檔的通用 import 機制 |

### 機器獨用檔案（不上 GitHub）

| 檔案 | 職責 |
|---|---|
| `hostname.nix` | `networking.hostName` |
| `local.nix` | `NIX_PROFILE` 與硬碟掛載（`fileSystems`） |
| `local-apps.nix` | 機器獨用的套件、服務、硬體特化設定 |
| `profiles/gpu-desktop.nix` | **顯卡驅動流派**（AMD 或 NVIDIA） |
| `hardware-configuration.nix` | 硬體掛載（`nixos-generate-config` 產生，**每台 UUID 不同**） |

每個都有對應的 `.example` 範本，會上 GitHub——**除了 `hardware-configuration.nix`**（見第四段說明）。

---

## 三、`local-files.txt` 機制

### 檔案內容

```text
# 📄 機器獨用檔清單（非同步檔的「單一事實來源」）
#
# 意義：jj 看得到（在 repo 裡、未被 .gitignore）、Nix build 要讀、但永不推到 GitHub 的檔。

hostname.nix
local-apps.nix
local.nix
profiles/gpu-desktop.nix
```

### 誰在讀這份清單

1. **`modules/local-files.nix`**（Nix 端）
   - 逐行讀清單，每行對應一個模組
   - 本機有實體檔 → 用實體檔
   - 沒有 → fallback 到 `<名稱>.example`
   - 這樣新機器 clone 下來、還沒建實體檔時，`nix eval` 不會炸

2. **`nppush` / `nppull`**（zsh 端，定義在 `home.nix` 的 `initContent`）
   - 讀同一份清單，組出 jj fileset
   - 推送時自動排除這些檔，確保機器獨用內容不會上 GitHub

---

## 四、關鍵陷阱：Nix flake 必須「看得到」檔案
這是本機制最重要的一點，也是**最容易踩的坑**。

### 問題

Nix flake 在 build 時，**只會看到 Git 追蹤的檔案**。未被追蹤的檔案，Nix 會報：

```
error: Path 'profiles/gpu-desktop.nix' in the repository "/home/wmt/.config/nixos" is not tracked by Git.
```

### 為什麼不能簡單地 `git rm --cached`

把機器獨用檔改成「未追蹤」（`git rm --cached`）看起來最乾淨，但會導致：

1. `nix flake check` 失敗
2. `nh os switch` 失敗
3. 整個 rebuild 卡住

### 正確解法：追蹤，但用 `jj split` 排除

機器獨用檔**必須被 Git 追蹤**（讓 Nix 讀得到），但**內容不進 commit**（讓 GitHub 拿不到）。

這正是 `nppush` 做的事：

```bash
jj split -m "$1" "$_fs"
```

`$_fs` 是 `all() ~ ("hostname.nix"|"local-apps.nix"|"local.nix"|"profiles/gpu-desktop.nix")`，
意思是「所有改動**除了**這些檔」。所以：

- 共享檔的修改 → 進 commit → 推上 GitHub
- 機器獨用檔的修改 → 留在 working copy → 不進 commit → 不推

### 遠端倉庫的狀態

遠端（GitHub）**只會有 `.example` 範本**，不會有實體檔。新機器 clone 下來的狀態是：

```
hostname.nix.example
local-apps.nix.example
local.nix.example
profiles/gpu-desktop.nix.example
local-files.txt
```

第一次使用要做的三步：

```bash
cd ~/.config/nixos
cp hostname.nix.example hostname.nix        # 改成這台的名字
cp local.nix.example local.nix              # 依這台調整 profile / 硬碟
cp local-apps.nix.example local-apps.nix    # 寫這台的獨用 app
cp profiles/gpu-desktop.nix.example profiles/gpu-desktop.nix  # 解開這台的顯卡流派
git add hostname.nix local-apps.nix local.nix profiles/gpu-desktop.nix
nh os switch ~/.config/nixos -H gpu-profile
```

---

### 🔴 最危險的案例：`hardware-configuration.nix` 被污染

2026-11-09 實際遇到：nvidia-nixos 同步時，`hardware-configuration.nix` 被覆蓋成 **amd 機器**的版本。

後果非常嚴重：

| 項目 | 錯誤檔案（amd 的） | 這台真實的 UUID |
|---|---|---|
| 根分割區 | `b05d6c10-b668-48cd-b94a-4719fc02c6ba` | `ef3fec20-e954-421b-88ae-30ada65b53c5` |
| EFI 分割區 | `378B-8036` | `4EA2-EA4A` |

若照這個檔案 rebuild，開機會**找不到根分割區，直接無法開機**。

**為什麼會發生**：`hardware-configuration.nix` 原本由 `nixos-generate-config` 產生，各機內容不同，但它曾被 git 追蹤並被 push/merge 到另一台。

**檢查自己這台的 UUID 是否正確**：

```bash
# 檔案裡寫的
grep -E "by-uuid" ~/.config/nixos/hardware-configuration.nix

# 實際的
findmnt -n -o UUID,SOURCE /
findmnt -n -o UUID,SOURCE /boot
```

兩者**必須一致**。不一致就重新產生：

```bash
sudo nixos-generate-config --dir /tmp/hwgen
cp /tmp/hwgen/hardware-configuration.nix ~/.config/nixos/hardware-configuration.nix
git add ~/.config/nixos/hardware-configuration.nix
```

**為什麼這個檔案要列進 `local-files.txt`**：列進去 = 被 `nppush` 排除，各機保持自己的版本，不會互推。

**但它沒有 `.example` 範本**，因為硬體設定沒有通用範本可言（用錯的 UUID 會開不了機）。所以 `modules/local-files.nix` 對這類檔案的規則是：

```nix
if builtins.pathExists real then real          # 有實體檔就用
else if builtins.pathExists example then example  # 有範本才 fallback
else null                                       # 都沒有就跳過，不報錯
```

`hardware-configuration.nix` 屬於第三種情況：各機自己產生，不靠範本。

**`configuration.nix` 對應的改法**：不再直接 `import ./hardware-configuration.nix`，改由 `modules/local-files.nix` 統一引入，避免重複：

```nix
imports = [
  ./packages.nix
  ./users.nix
  ./modules/local-files.nix   # ← 含 hardware-configuration.nix
];
```

---

## 五、日常操作流程

### 修改共享設定（會同步到所有機器）

```bash
cd ~/.config/nixos
jj st                      # 看改動
nr                         # jj st + nh os switch，rebuild 生效
nppush "feat: 說明"        # 推送共享改動（自動排除機器獨用檔）
```

### 只改這台的機器獨用設定

```bash
cd ~/.config/nixos
nvim local-apps.nix        # 或 hostname.nix / local.nix / profiles/gpu-desktop.nix
nr                         # 直接 rebuild（這些檔不需要推送）
```

### 從 GitHub 拉取其他機器的共享更新

```bash
cd ~/.config/nixos
nppull                     # jj fetch + rebase + nh os switch
```

`nppull` 有三道防呆：

| 防呆 | 檢查什麼 | 不符合時 |
|---|---|---|
| 一 | 本機 main 是否超前遠端 | 有未推送 commit → 拒絕，提示先 `nppush` |
| 二 | 是否有未提交的**共享**修改 | 有 → 拒絕（機器獨用檔的改動不算） |
| 三 | `@-` 是否已等於 `main@origin` | 相同 → 跳過 rebuild，省時間 |

---

## 六、aliases 一覽

定義在 `home.nix` 的 `shellAliases`：

| alias | 實際指令 | 用途 |
|---|---|---|
| `nr` | `jj st && nh os switch ~/.config/nixos -H ${NIX_PROFILE:-gpu-profile} && exec zsh` | 重建並生效 |
| `nru` | 同 `nr` 加 `-u` | 重建並更新所有 flake inputs |
| `nrt` | `jj st && nh os test ...` | 只測試建置，不生效 |
| `nrb` | `jj st && nh os boot ...` | 設為開機預設，不立即生效 |
| `nc` | `nh clean all --keep 5` | 清理舊 generation |
| `nppush` | 見上文 | 推送共享改動 |
| `nppull` | 見上文 | 拉取共享更新 |

`NIX_PROFILE` 由 `local.nix` 的 `environment.sessionVariables` 設定，所以每台機器的 alias 自動指向正確的 profile。

---

## 七、新增機器獨用檔的步驟

假設要新增一個 `local-secrets.nix`：

1. **寫範本**（會上 GitHub）

   建立 `local-secrets.nix.example`，內容放通用骨架與說明。

2. **加進清單**

   在 `local-files.txt` 補一行：

   ```text
   local-secrets.nix
   ```

3. **各機建立實體檔**

   ```bash
   cp local-secrets.nix.example local-secrets.nix
   # 改成這台需要的內容
   git add local-secrets.nix
   ```

4. **驗證**

   ```bash
   nix flake check --no-build
   nr
   ```

之後 `nppush` 會自動排除它，不需要改任何腳本。

---

## 八、顯卡流派切換（`profiles/gpu-desktop.nix`）

這是**最容易搞錯**的部分。兩台機器的驅動完全不同：

### AMD 機器（`wmt-amd-nixos`）

```nix
# 🏎️ 流派 A：AMD 顯示卡（作用中）
boot.initrd.kernelModules = [ "amdgpu" ];
services.xserver.videoDrivers = [ "amdgpu" ];
hardware.cpu.amd.updateMicrocode = true;
hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];

# 🟢 流派 B：NVIDIA 顯示卡（註解）
# boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
# services.xserver.videoDrivers = [ "nvidia" ];
# hardware.nvidia = { ... };
```

### NVIDIA 機器（`wmt-nvidia-nixos`，RTX 5090 + Intel CPU）

```nix
# 🏎️ 流派 A：AMD 顯示卡（註解）
# boot.initrd.kernelModules = [ "amdgpu" ];
# services.xserver.videoDrivers = [ "amdgpu" ];
# hardware.cpu.amd.updateMicrocode = true;

# 🟢 流派 B：NVIDIA 顯示卡（作用中）
boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  package = config.boot.kernelPackages.nvidiaPackages.latest;
  modesetting.enable = true;
  powerManagement.enable = true;
  open = true;
  nvidiaSettings = true;
};
```

### 注意事項

| 項目 | AMD 機 | NVIDIA 機 |
|---|---|---|
| CPU 微碼 | `hardware.cpu.amd.updateMicrocode = true` | ❌ 不要加（Intel CPU） |
| `amd_pstate` kernel param | ✅ 有用 | ❌ 無效，不要在 `configuration-fix.nix` 加 |
| GPU 監控工具 | `amdgpu_top` | `nvtopPackages.nvidia` |
| ROCm | ✅ `rocmPackages.clr.icd` | ❌ 不需要 |
| GameMode `gpu_device` | `card1`（自動判定） | `card0`（自動判定） |

### ⚠️ NVIDIA 機器的核心版本陷阱（2026-11 實測）

NVIDIA 595.71.05 驅動**編不過 Linux 7.2.8**，會失敗並中止整個 rebuild：

```
nvidia/os-interface.c:764:5: error: implicit declaration of function 'strncpy'
```

原因：Linux 7.x 移除了一些隱含的 `<string.h>` 引入，NVIDIA 舊版原始碼沒顯式 include。

**這是「共享骨架不能直接套用」的典型案例**——`gpu-desktop.nix.example` 預設用 `linuxPackages_latest`，
AMD 機器吃最新核心沒問題，NVIDIA 機器會編不過。

**NVIDIA 機器的解法**：改用 nixpkgs 穩定核心，不用 `_latest`：

```nix
# ❌ 會編不過
boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;   # 7.2.8

# ✅ 正確
boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;          # 6.18.x
```

**版本對照（2026-11-09 實測）**：

| 核心套件 | 版本 | NVIDIA 595.71.05 |
|---|---|---|
| `linuxPackages_latest` | 7.2.8 | ❌ `strncpy` 隱含宣告失敗 |
| `linuxPackages` | 6.18.54 | ✅ 可編譯 |
| `linuxPackages_xanmod` | 6.18.54 | ✅ 可編譯（gaming specialisation 也用這個） |

未來 NVIDIA 推出修復版驅動後，可再改回 `_latest`。查目前 NVIDIA 版本的方式：

```bash
nix eval --raw .#nixosConfigurations.gpu-profile.pkgs.linuxPackages.nvidiaPackages.latest.version
```

若 nixpkgs 已更新到能編譯 7.x 的驅動版本，就可以解開這個鎖。

`gpu_device` 的判斷寫法是自動的：

```nix
gpu_device = if (builtins.elem "nvidia" config.services.xserver.videoDrivers) then 0 else 1;
```

---

## 九、故障排除

### `error: Path 'xxx' in the repository is not tracked by Git`

**原因**：機器獨用檔被 `git rm --cached` 了，或新建立的檔案忘了 `git add`。

**解法**：

```bash
git add hostname.nix local-apps.nix local.nix profiles/gpu-desktop.nix
```

### `error: undefined variable 'gpu-profile'`

**原因**：`home.nix` 的 Nix 字串裡寫了 `${NIX_PROFILE:-gpu-profile}`，Nix 把 `gpu-profile` 當成插值變數。

**解法**：用 `''` 跳脫成 shell 變數：

```nix
nh os switch ~/.config/nixos -H \''${NIX_PROFILE:-gpu-profile}
```

注意是 `\''${...}`，不是 `\${...}`。

### `nvidia/os-interface.c: implicit declaration of function 'strncpy'`

**原因**：NVIDIA 驅動版本太舊，編不過新版 Linux 核心（7.x）。這會讓整個 rebuild 中止。

**解法**：把核心降到 nixpkgs 穩定版（見第八段「NVIDIA 機器的核心版本陷阱」）。

```nix
boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;  # 不要用 _latest
```

### `nh os switch` 卡在密碼

**原因**：NixOS 的中文 locale 提示是 `[sudo] wmt 的密碼：`（全形冒號），非互動環境的 expect 若只比對英文 `Password:` 會逾時。

**解法**：expect 要同時比對 `assword:` 與 `\u5bc6\u78bc`（「密碼」的 unicode escape）。Tcl 的 regex 不能直接寫全形冒號。

### `nppush` 說「沒有可推的共享修改」

**原因**：你只改了機器獨用檔，或根本沒改動。

**解法**：這是正常行為。要推機器獨用檔是**不該做的事**——那正是這套機制要防止的。

### 遠端出現實體檔（違反設計）

**原因**：不小心用 `git add -A && git commit` 或 `git push` 把機器獨用檔推上去了。

**解法**：

```bash
git rm --cached hostname.nix local-apps.nix local.nix profiles/gpu-desktop.nix
git commit -m "fix: 遠端移除機器獨用實體檔，只保留 .example 範本"
git push origin main
```

⚠️ **不要用 `git rm`（不加 `--cached`）**，那會把本機檔案也刪掉。

---

## 十、與 Mac（`nix-darwin`）的差異

| 項目 | Mac `nix-darwin` | NixOS |
|---|---|---|
| 機器獨用檔 | `hostname.nix`、`local-apps.nix`、`local-taskrc.nix` | `hostname.nix`、`local-apps.nix`、`local.nix`、`profiles/gpu-desktop.nix` |
| 清單檔 | `local-files.txt` | `local-files.txt` |
| 通用 import | `modules/local-files.nix` | `modules/local-files.nix` |
| rebuild alias | `nr` → `nh darwin switch` | `nr` → `nh os switch` |
| 推送函數 | `nppush` / `nppull` | `nppush` / `nppull`（同邏輯） |
| Git 工具 | jj 0.46 | jj 0.41 |
| 套件來源 | brew cask + mas | nixpkgs |

兩邊的機制**完全同構**，差別只在重建指令與套件來源。

---

## 十一、機器清單

| 機器 | hostname | 顯卡 | `NIX_PROFILE` | 備註 |
|---|---|---|---|---|
| amd 工作站 | `wmt-amd-nixos` | AMD RX 5700 XT | `gpu-profile` | Steam 資料碟掛載在 `/mnt/steam-storage` |
| nvidia 工作站 | `wmt-nvidia-nixos` | NVIDIA RTX 5090 | `gpu-profile` | Intel Core Ultra 7 265K |
| Mac | `JimmydeMacBook-Pro` | Apple Silicon | N/A | 走 `nix-darwin`，獨立 repo |

---

## 十二、歷史紀錄

| 日期 | 事件 |
|---|---|
| 2026-11-09 | 建立本機制：拆分 `local.nix`、新增 `hostname.nix` / `local-apps.nix`、移植 `local-files.txt`、移除 `pve-profile` |
| 2026-11-09 | 將 `profiles/gpu-desktop.nix` 納入機器獨用機制（AMD / NVIDIA 兩台驅動不同） |
| 2026-11-09 | 遠端移除機器獨用實體檔，只保留 `.example` 範本 |
| 2026-11-09 | nvidia-nixos 修正顯卡流派（`amdgpu` → `nvidia`），並將核心鎖在 `linuxPackages` 6.18 解決驅動編譯失敗 |
| 2026-11-09 | 發現 `hardware-configuration.nix` 被 amd 版本污染（UUID 不符，會導致無法開機），重新產生正確版本並納入 `local-files.txt`；`modules/local-files.nix` 改為「缺檔就跳過」 |

---

*本文件由 amd-nixos 端維護，最後更新：2026-11-09*

<!-- nppush/nppull 雙向驗證 2026-11-10-2017 -->
