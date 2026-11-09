# 🚀 NixOS 軟體與工具使用手冊

這份文件彙整了目前系統中安裝的所有工具、桌面環境（Sway）的快捷鍵設定，以及終端機現代化工具的實戰用法。

---

## 📑 目錄
1. [🌀 Sway 桌面環境與快捷鍵指南](#-1-sway-桌面環境與快捷鍵指南)
2. [🖥️ 桌面圖形應用程式 (GUI Apps)](#️-2-桌面圖形應用程式-gui-apps)
3. [⚡ 系統管理與重構 (Nix Helper & Aliases)](#-3-系統管理與重構-nix-helper--aliases)
4. [🦀 現代化終端機 CLI 刀組 (Modern Rust & CLI Tools)](#-4-現代化終端機-cli-刀組-modern-rust--cli-tools)

---

## 🌀 1. Sway 桌面環境與快捷鍵指南

> 註：`Super` 鍵為鍵盤上的 `Windows` 鍵（Mod4）。

### 🪟 視窗與版面管理
| 快捷鍵 | 功能說明 |
| :--- | :--- |
| `Super + Return` | 啟動 **Ghostty** 終端機 |
| `Super + Shift + Return` | 啟動 **Google Chrome** 瀏覽器 |
| `Super + Shift + Q` | 關閉 / 殺死當前聚焦視窗 |
| `Super + Shift + C` | 重新載入 Sway 設定檔（無需重啟） |
| `Super + M` | 切換視窗全螢幕 / 還原 |
| `Super + Shift + Space` | 切換視窗浮動 / 平鋪模式 |
| `Super + B` | 水平切割下一個新視窗（Split Horizontal） |
| `Super + V` | 垂直切割下一個新視窗（Split Vertical） |
| `Super + W` | 分頁籤模式（Tabbed layout） |
| `Super + E` | 切換分割模式（Toggle Split） |
| `Super + H / J / K / L` | 移動視窗焦點（左 / 下 / 上 / 右） |
| `Super + Shift + H / J / K / L` | 移動當前視窗位置（左 / 下 / 上 / 右） |
| `Super + 1 ~ 9` | 切換到第 1 ~ 9 虛擬工作區 |
| `Super + Shift + 1 ~ 9` | 將當前視窗移至第 1 ~ 9 虛擬工作區 |

---

### 🚀 桌面小工具與操作捷徑
| 快捷鍵 | 元件 / 指令 | 說明 |
| :--- | :--- | :--- |
| `Super + D` | **Walker** | 全方位生產力啟動器（搜尋 App、即時計算、執行指令、網頁搜尋） |
| `Super + Shift + D` | **nwg-drawer** | 全螢幕圖形化 App 抽屜面板 |
| `Super + Shift + N` | **SwayNC** | 展開 / 收合現代化通知中心（音量滑桿、勿擾、音樂控制） |
| `Super + C` | **Walker Clipboard** | 召喚剪貼簿歷史搜尋選單（支援圖片預覽、釘選、快速貼上） |
| `Super + Tab` | **Walker Windows** | 跨工作區開啟視窗搜尋與跳轉切換器（即時模糊比對標題與聚焦） |
| `Super + =` | **Qalc (Popup)** | 瞬間彈出懸浮計算機終端視窗 |
| `Super + O` | **Jump Folder** | 終端機 (Ghostty) 與檔案管理器 (Thunar) 雙向無縫跳轉（保持同一工作目錄） |
| `Super + Shift + P` | **Hyprpicker** | 螢幕滴管取色工具（點擊像素自動複製 Hex 色碼） |

---

### 📸 截圖快捷鍵（對齊 macOS / Windows 雙棲直覺）
截圖均直接串接 **Satty** 標註神器，支援畫筆、箭頭、矩形、**馬賽克/模糊**，並以 `Enter` 快速存檔與複製。

| 快捷鍵 | 模式 | 操作細節 |
| :--- | :--- | :--- |
| **`Super + Ctrl + W`**<br>`Super + Ctrl + Shift + 5` | **純視窗截圖**<br>(macOS 相機模式) | 游標移到任何視窗會自動高亮，**滑鼠單擊即可精準截取該視窗**。 |
| **`Super + Ctrl + S`**<br>`Super + Ctrl + Shift + 4` | **智慧雙棲截圖** | **點擊視窗**：自動吸附截取整片視窗。<br>**拖曳滑鼠**：自由框選任意矩形區域。 |
| `Super + Ctrl + Shift + 3` | **全螢幕截圖** | 瞬間截取當前螢幕所有畫面。 |

---

### 🔊 媒體與硬體按鍵 (SwayOSD 即時螢幕膠囊顯示)
* **音量調整**：`VolumeUp` (+5%) / `VolumeDown` (-5%) / `Mute` (喇叭靜音) / `MicMute` (麥克風靜音) — 串接 **SwayOSD** 彈出動態進度膠囊（最高音量鎖定 100% 防破音）。
* **螢幕亮度**：`BrightnessUp` (+5%) / `BrightnessDown` (-5%) — 透過 SwayOSD 顯示螢幕亮度平滑進度條。
* **媒體控制**：`MediaPlay` (播放/暫停) / `MediaNext` (下一首) / `MediaPrev` (上一首) — 顯示播放狀態與曲目切換圖示。
* **大寫鎖定**：按壓 `Caps_Lock` 鍵釋放時，即時於螢幕彈出目前大小寫鎖定狀態。

---

## 🖥️ 2. 桌面圖形應用程式 (GUI Apps)

### 🎛️ 系統與硬體設定
* **Waybar**：頂部狀態列。右側鈴鐺圖示左鍵開啟通知中心、右鍵快速切換勿擾模式；電源圖示開啟關機選單。
* **wdisplays**：Sway 專屬圖形化螢幕管理面板，可用滑鼠拖曳排列雙螢幕、調整解析度與更新率。
* **waypaper**：動態桌布選擇器（搭配 `awww` 引擎），點擊圖片即時切換桌布。
* **pavucontrol**：音效控制台（音量混音器），可為特定耳機/喇叭設定輸出，或指定個別瀏覽器/遊戲的音訊裝置。
* **EasyEffects**：PipeWire 專業級系統音效 DSP 處理器（常駐背景，提供 RNNoise / DeepFilterNet 麥克風 AI 降噪、AutoEQ 耳機哈曼曲線校準、Limiter 防爆音保護）。
* **blueman-manager**：圖形化藍牙管理工具，配對、連接藍牙耳機與手把。
* **cpu-x**：Linux 版 CPU-Z，即時監看處理器頻率、快取、主機板與記憶體參數。
* **hardinfo2**：經典裝置管理員，樹狀列出所有周邊硬體並提供跑分測試。
* **system-config-printer**：印表機設定面板。
* **simple-scan**：極簡文件/照片掃描工具。
* **seahorse**：GNOME 密鑰環與 SSH Key 管理介面。
* **swayidle & sway-audio-idle-inhibit**：智慧螢幕防線。閒置 5 分鐘自動鎖定螢幕（`swaylock`），保持螢幕訊號輸出避免 DisplayPort 關閉後喚醒失敗黑屏；若背景正在播放音訊（如 YouTube、Spotify、線上會議），自動抑制鎖定防黑屏。
* **wlogout**：Wayland 專用沉浸式關機/重開機/登出/鎖屏選單。

### 💼 文書辦公、閱讀與創作
* **Sioyek** (`sioyek`)：專為學術論文與厚重教材打造的黑科技 PDF 閱讀器。支援 Portal（傳送門釘選圖表）、Smart Jump（點擊引用文獻瞬移並一鍵返回）、焦點尺標與智慧保留彩色圖片的抗疲勞夜間模式。
* **ONLYOFFICE** (`onlyoffice-desktopeditors`)：完全相容微軟 Office 格式的文書套件（Word、Excel、PowerPoint）。
* **Zathura**：極速硬派純鍵盤 PDF 閱讀器（Vim 鍵位），支援與 Neovim 的 SyncTeX 雙向跳轉。
* **Okular**：功能全面的文件/PDF 閱讀器，支援螢光筆標註與批註功能。
* **Geeqie**：輕巧極速的圖片檢視器，支援 RAW 檔與目錄連續瀏覽。
* **RStudio** (`rstudio`)：R 語言統計分析專用 IDE。
* **File Roller** (`file-roller`)：GTK 壓縮檔管理器，可圖形化檢視並解壓縮各種壓縮包。
* **Thunar**：輕巧好用的 XFCE 檔案管理器（已整合右鍵「在此開啟 Ghostty 終端機」，並支援透過 `Super + O` 與終端機雙向目錄跳轉）。

### 💬 社群通訊
* **Telegram Desktop** (`telegram-desktop`)：原生支援 Wayland 的 Telegram 客戶端（預設固定於 Workspace 2）。
* **Karere** (`karere`)：WhatsApp 專用桌面版客戶端（預設固定於 Workspace 2）。
* **WeChat** (`wechat`)：微信 Linux 官方桌面客戶端。
* **LINE**：自訂 Chrome 獨立沙盒視窗執行。

### 🎮 遊戲生態
* **Steam**：已整合官方優化、Gamescope 與 Proton 環境。
* **Heroic Games Launcher**：Epic Games、GOG 與 Amazon 遊戲的前端管理程式。
* **Protontricks** (`protontricks --gui`)：Proton 遊戲容器手術刀，一鍵修復遊戲內缺字、補齊 DirectX/VC++ 運行庫或注入外掛/漢化補丁。

---

## ⚡ 3. 系統管理與重構 (Nix Helper & Aliases)

系統已配置 `nh` (Yet Another Nix Helper) 與預編譯全域索引 `nix-index`，大幅加速重建與套件搜尋：

| 別名 (Alias) | 完整執行行為 | 說明 |
| :--- | :--- | :--- |
| **`nr`** | `git add -A && nh os switch ~/.config/nixos -H $NIX_PROFILE && exec zsh` | **最常用：一鍵重構並套用新配置** |
| **`nru`** | `git add -A && nh os switch ~/.config/nixos -H $NIX_PROFILE -u && exec zsh` | **更新所有 flake 依賴 (update inputs) 並套用** |
| `nrt` | `git add -A && nh os test ~/.config/nixos -H $NIX_PROFILE` | 測試新配置（不寫入 boot 開機選單） |
| `nrb` | `git add -A && nh os boot ~/.config/nixos -H $NIX_PROFILE` | 寫入開機選單（下次重啟時生效） |
| `nc` | `nh clean all --keep 5` | 清理舊世代垃圾，僅保留最近 5 個系統世代 |
| `nxc` | `sudo nix-collect-garbage --delete-old` | 系統級垃圾收集 |
| `nxcg` | `nix-collect-garbage -d && sudo nix-collect-garbage -d` | 深度徹底清空所有用戶與系統舊世代 |
| `nxl` | `sudo nixos-rebuild list-generations` | 列出歷史系統世代清單 |

### 逗號神器 `comma` (`,`)
免安裝即可直接執行任何 Nixpkgs 軟體倉庫裡的指令：
```bash
, htop            # 免預先安裝，自動下載執行 htop
, cowsay "Hello"  # 快速執行一次性工具
```

### 🚨 記憶體守護者 `earlyoom`
常駐於背景的系統級記憶體保護服務。當可用記憶體或 Swap 低於 10% 時，主動提前介入終止失控暴衝的進程（例如過度編譯、記憶體洩漏程式），避免 Linux 核心預設 OOM 延遲反應導致全系統滑鼠畫面卡死凍結。

### 🌳 Nix 依賴樹與體積分析 `nix-tree` & `nix-du`
* **`nix-tree`**：以互動式 TUI 介面穿透探索 Nix Derivation 與 `/nix/store` 的依賴關係與體積佔用。
  * **直接執行**：`nix-tree`（預設分析當前系統 `/var/run/current-system`）
  * **常用操作**：
    * `hjkl` 或方向鍵：瀏覽與層層展開依賴樹
    * `s`：依「套件自身體積（Narr Size）」或「完整閉包體積（Closure Size）」切換排序
    * `/`：即時關鍵字搜尋特定套件
    * `w`：**Why-depends**（精準查詢這個套件到底是被哪一個上游依賴拉進系統的）
    * `y`：複製當前選中的 Nix Store Path 到剪貼簿
    * `q` / `Esc`：退出
* **`nix-du`**：視覺化分析垃圾回收根節點（GC Roots）與磁碟佔用關係。
  * 範例：`nix-du -s 500MB | dot -Tsvg > nix-du.svg`（生成各模組根節點佔用拓撲圖）

### 🌲 彩色即時建構樹 `nix-output-monitor` (`nom`)
取代傳統 Nix 滾動純文字的即時建構監控神器。
* **自動整合**：系統重構工具 `nh` 會自動偵測並調用 `nom`，將下載與平行編譯繪製為彩色即時 DAG 進度條與狀態樹。
* **獨立建構**：亦可手動代替 `nix build`，例如：`nom build .#nixosConfigurations.gpu-profile.config.system.build.toplevel`

---

## 🦀 4. 現代化終端機 CLI 刀組 (Modern Rust & CLI Tools)

### 🔍 檔案瀏覽、搜尋與取代
* **`ripgrep` (`rg`)**：宇宙最快純文字搜尋工具（自動忽略 `.gitignore`）。
  * 範例：`rg "pattern"`、`rg -i "pattern" src/`
* **`fd`**：取代 `find` 的現代化搜尋工具。
  * 範例：`fd ".nix$"`（找特定副檔名）、`fd -H secret`（包含隱藏檔搜尋）
* **`bat`**（已 alias 為 `cat`）：帶有語法高亮、Git 修改標記與行號的文字預覽工具。
  * 範例：`cat configuration.nix`
* **`yazi`**（已 alias 為 `y`）：全非同步 Rust 終端檔案管理器，支援圖片即時預覽。
  * 範例：`y`
* **`zoxide`**（已整合為 `cd`）：智慧目錄跳轉工具，會記住你常去的目錄。
  * 範例：`cd nixos` 即可直接瞬移至 `~/.config/nixos`。
* **`fzf`**：終端機模糊搜尋神器，支援與 Shell 補全深度整合。
* **`dust`**：直覺樹狀圖顯示資料夾佔用空間（取代 `du`）。
  * 範例：`dust` 或 `dust -d 2`（限制層數）
* **`trash-cli`**：安全回收桶替代方案，防止 `rm -rf` 誤刪悲劇。
  * 範例：`trash <file>`（丟入回收桶）、`trash-list`（檢視）、`trash-restore`（復原）
* **`sd`**：極速直覺的現代化正則文字替換工具（Rust，終結 `sed` 的跳脫字元惡夢）。
  * 範例：`sd '舊文字' '新文字' file.txt`
  * 範例：`sd -s '127.0.0.1' 'localhost' config.yaml`（`-s` 代表精確字串比對，不當作正則）

---

### 📊 系統效能、進程與硬體監控
* **`btop`**（已 alias 為 `top`）：現代 TUI 監視器顏值天花板，已整合 AMD ROCm 支援顯示 Radeon RX 5700 XT 負載、溫度、功耗與 VRAM 面板，支援全彩 CPU 曲線、進程樹、磁碟 I/O 與網路監控，支援 Vim (`hjkl`) 鍵位導航。
* **`procs`**：現代化彩色進程檢視工具（取代 `ps`）。
  * 範例：`procs steam`
* **`fastfetch`**：極速系統規格總覽與 Neofetch 現代化替代品。
* **`amdgpu_top`**：AMD 顯示卡專屬即時負載、功耗、VRAM 監控器。
* **`smartctl`** (`smartmontools`)：硬碟健康狀態與壽命檢查。
  * 範例：`sudo smartctl -a /dev/nvme0n1`
* **硬體周邊查詢**：
  * `lspci -nnk | grep -iA 3 vga`（檢視 GPU 驅動狀態）
  * `lsusb -t`（樹狀檢視 USB 裝置）
  * `lsblk -f`（檢視所有硬碟磁區、UUID 與檔案系統格式）

---

### ⏱️ 終端增強與生活好幫手
* **`atuin`**：SQLite 驅動的魔法歷史紀錄管理器。
  * **使用方式**：在終端機按下 **`Ctrl + R`** 喚起搜尋面板；支援模糊比對、執行目錄過濾、成功/失敗狀態過濾。
  * *(保留方向鍵 `↑` 翻閱前一指令的習慣)*
* **`tealdeer` (`tldr`)**：极速指令範例手冊，告別落落長的 man 文件。
  * 範例：`tldr tar`、`tldr rsync`、`tldr ffmpeg`
* **`xdg-ninja`**：家目錄強迫症診斷工具。
  * 範例：在終端機直接輸入 `xdg-ninja`，會自動找出亂丟在 `~` 的設定檔並提供搬遷建議。
* **`hyperfine`**：命令列基準測試工具，精準測量指令執行耗時。
  * 範例：`hyperfine 'fd test' 'find . -name test'`
* **`tokei`**：統計專案程式碼行數、語言佔比與註解量。
  * 範例：`tokei .`
* **`delta`**：極美的語法高亮 Git Diff 工具（已自動掛載於 Git）。
* **`tmux`**：硬派終端複用器。

---

### 📈 終端試算表與計算機
* **`qalc`**：強大自由度極高的自然語言單位換算與計算機。
  * 範例：`qalc "100 USD to TWD"`、`qalc "sqrt(2) * 5"`
* **`visidata` (`vd`)**：終端機百萬行資料集/CSV/JSON 秒開檢視與探索工具。
  * 範例：`vd data.csv`
* **`sc-im`**：Vim 鍵位的終端純文字試算表程式。
* **`jq`**：命令列 JSON 高效解析器。

---

### 🌐 網路傳輸與遠端工具
* **`aria2c`**（已 alias 為 `aria`）：多執行緒高速下載工具。
  * 範例：`aria -x 16 -s 16 "URL"`
* **`croc`**：跨平台終端點對點（P2P）端對端加密檔案快傳工具。
  * 傳送端：`croc send filename`
  * 接收端：`croc <code>`
* **`LocalSend`** (`localsend`)：跨平台開源 AirDrop（支援 Linux / macOS / iOS / Android / Windows）。
  * **使用方式**：直接從 Walker 搜尋 `localsend` 開啟，或在終端輸入 `localsend`。
  * **特色**：同區網 P2P 秒傳、免帳號無雲端中繼、支援即時文字/剪貼簿傳送與大檔高速直傳（防火牆已自動放行 53317 埠）。
* **`xh`**：極速、高顏值的現代化 HTTP / REST API 命令列工具（Rust，全面升級 `curl` 與 `httpie`）。
  * 範例：`xh get https://httpbin.org/json`（自動高亮與格式化 JSON）
  * 範例：`xh post :8000/api name=Jimmy age:=25`（自動設定 Content-Type 與 JSON 數字型別）
  * 範例：`xh -d https://example.com/file.zip`（類似 `curl -O` 下載檔案並顯示進度條）
* **`rsync`** / **`rclone`**：強大的本地/雲端硬碟同步備份工具。
* **外接硬碟別名**：
  * `mn /dev/sdX1`：安全掛載
  * `umn /dev/sdX1`：安全卸載
  * `poff /dev/sdX`：安全切斷外接硬碟電源（拔出不傷硬碟）
