# 🚀 Sway 平鋪式視窗管理器 (Tiling WM) 終極指南

Sway 是一款為 **Wayland** 打造的 100% i3 相容平鋪式視窗管理器。它的核心哲學是 **「鍵盤優先（Keyboard-First）、零視覺雜訊、自動高效佈局」**。

## 📌 1. 核心概念與修飾鍵 (Modifier Key)

在 Sway 中，絕大多數操作都圍繞著 **`$mod`** 鍵展開：

- 通常預設為 **`Super` 鍵**（即 Windows 鍵 / Mac 上的 Command 鍵）。
- 部分預設設定亦可能綁定為 **`Alt` 鍵**。

### 視窗樹狀結構 (Container Tree)

Sway 將螢幕上的視窗視為「容器 (Container)」。視窗可以水平（Horizontal）或垂直（Vertical）切割，也可以組合成分頁（Tabbed）或堆疊（Stacked）樣式。

## ⚡ 2. 基礎導航與視窗控制

Sway 預設完全採用 **Vim 風格鍵位 (`hjkl`)**：

| **功能** | **預設快捷鍵** | **說明** |
| **開啟終端機** | `$mod + Enter` | 開啟預設 Terminal (如 Foot, Kitty) |
| **關閉當前視窗** | `$mod + Shift + q` | 關閉 Focal 視窗（同 `kill`） |
| **開啟應用程式選單** | `$mod + d` | 觸發 Launcher (如 Wofi, Fuzzel, Rofi) |
| **重新載入設定檔** | `$mod + Shift + c` | 更改 config 後即時生效 |
| **退出 Sway** | `$mod + Shift + e` | 登出 / 退出視窗管理器 |

### 🎯 視窗焦點移動 (Focus)

- `$mod + h`：焦點向**左**移動
- `$mod + j`：焦點向**下**移動
- `$mod + k`：焦點向**上**移動
- `$mod + l`：焦點向**右**移動
- `$mod + Space`：在「平鋪視窗」與「浮動視窗」之間切換焦點

### 📦 搬移視窗位置 (Move)

- `$mod + Shift + h`：將視窗向**左**推
- `$mod + Shift + j`：將視窗向**下**推
- `$mod + Shift + k`：將視窗向**上**推
- `$mod + Shift + l`：將視窗向**右**推

## 📐 3. 佈局（Layout）與分割（Splitting）

### 視窗切割方向

新開視窗預設會沿著當前視窗的長邊自動二分。你可以手動指定下一個開啟視窗的切割方向：

- `$mod + b`：設定下一次開啟為 **水平切割 (Horizontal Split)**
- `$mod + v`：設定下一次開啟為 **垂直切割 (Vertical Split)**

### 佈局模式切換

- `$mod + e`：**Default (Split)** 模式（傳統平鋪）
- `$mod + w`：**Tabbed** 模式（分頁頁籤，類似瀏覽器 Tab，適合單螢幕放多視窗）
- `$mod + s`：**Stacked** 模式（垂直堆疊頁籤）
- `$mod + f`：**Fullscreen** 全螢幕開關（全螢幕時自動隱藏其他視窗與 Waybar）
- `$mod + Shift + Space`：**Toggle Floating**（將當前視窗轉為獨立浮動視窗）

## 🗂️ 4. 工作區 (Workspaces) 管理

Sway 的工作區是**動態建立**的，按了才會存在。

- **切換工作區**：`$mod + 1` ~ `$mod + 9`
- **將當前視窗搬移到指定工作區**：`$mod + Shift + 1` ~ `$mod + Shift + 9`
- **跨螢幕移動工作區**：
  若使用雙螢幕，可以使用 `swaymsg` 把整個 Workspace 搬到另一個顯示器：
  `$mod + Shift + Left` 或 `$mod + Shift + Right`

## 🛠️ 5. 進階工作流與黑科技功能

### 🗄️ A. Scratchpad（隨叫隨到的隱形抽屜）

這是 Sway/i3 最強大的功能之一。你可以把任何視窗（例如 Telegram、Spotify、系統監控 `btop`）藏進背景「抽屜」，隨時按快捷鍵呼叫出來，用完再收回去。

1. **把當前視窗收進 Scratchpad**：
   `$mod + Shift + minus` (`$mod + Shift + -`)
2. **呼叫 / 隱藏 Scratchpad 視窗**：
   `$mod + minus` (`$mod + -`)

### 📐 B. Resize Mode（調整視窗大小模式）

Sway 採用 Modal 模式調視窗大小：

1. 按下 `$mod + r` 進入 **`resize` 模式**。
2. 此時直接按 `h` / `j` / `k` / `l` 調整尺寸（不必按住 `$mod`）：
   - `h`：縮小寬度
   - `l`：增加寬度
   - `k`：減少高度
   - `j`：增加高度
3. **按下 `Esc` 或 `Enter` 退出模式**（非常重要，否則打字會卡在 resize 模式）。

> 💡 **滑鼠派解法**：按住 **`$mod` + 滑鼠右鍵拖曳** 即可隨時微調任何視窗大小，完全不必進入 Resize Mode。

### 🖱️ C. 滑鼠無縫互動

- **移動視窗**：按住 **`$mod` + 滑鼠左鍵拖曳** 任何視窗（包含浮動視窗）。
- **調整視窗大小**：按住 **`$mod` + 滑鼠右鍵拖曳**。

### 💻 D. CLI 控場大師：`swaymsg`

`swaymsg` 是 Sway 的 IPC 命令列工具，可以用於寫腳本自動化控場：

```bash
# 查詢當前所有工作區狀態 (JSON 格式)
swaymsg -t get_workspaces

# 用指令強制調整當前視窗透明度
swaymsg opacity set 0.85

# 關閉特定顯示器 (Output)
swaymsg output HDMI-A-1 disable

# 讓特定 App 啟動時自動浮動
for_window [app_id="pavucontrol"] floating enable
```

## 💡 6. 攻頂級工作流範例：LaTeX 寫作自動化排版

結合你的 **Neovim + Zathura + Sway** 終極寫作環境：

1. **打開工作區 1** (`$mod + 1`)。
2. **啟動 Neovim** (`$mod + Enter` -> `nvim paper.tex`)。
3. **觸發 Zathura 預覽**（在 Neovim 內按下 `<localleader>lv`）。
4. **Sway 的自動行為**：
   - Sway 自動將 Neovim 與 Zathura 作 50/50 左右分割。
   - 按下 **`$mod + w`** 亦可隨時把兩者切換成 **Tabbed** 頁籤模式。
5. **需要查資料時**：
   - 按下 `$mod + 2` 切到工作區 2 開啟瀏覽器，寫作心流完全不受干擾。
