# 🎹 Neovim Keymap Survival Guide (Cheat Sheet)

> **說明**：
>
> - `<Leader>` = `Space` (空白鍵)
> - `<LocalLeader>` = `\` (反斜線)
> - 此表根據您目前的設定檔與討論結果自動生成。

## 🚀 核心與介面 (Core & UI)

現在由 `Noice` 接管指令列，`Snacks` 接管通知與輸入框，分工明確。

| **按鍵組合**     | **功能**                    | **來源插件**    | **備註**                    |
| :--------------- | :-------------------------- | :-------------- | :-------------------------- |
| `:`              | **Command Line** (指令列)   | `noice.nvim`    | 支援 Blink 補全的現代化介面 |
| `<S-Enter>`      | Redirect Cmdline            | `noice.nvim`    | 將指令輸出導向到浮動視窗    |
| `<Esc>`          | 清除搜尋高亮 (No Highlight) | `which-key.lua` |                             |
| `\` + `fn`       | 通知歷史紀錄                | `snacks.nvim`   |                             |
| `\` + `rf`       | 重新命名檔案                | `snacks.nvim`   | 快速更名 (Input)            |
| `\` + `fP`       | 切換專案 (Projects)         | `snacks.nvim`   |                             |
| `<Space>` + `gg` | 開啟 LazyGit                | `snacks.nvim`   | 必備                        |
| `-`              | 開啟 **Oil** 檔案管理器     | `oil.nvim`      | 類 Buffer 編輯              |
| `\` + `fl`       | 切換 **File Explorer** 側欄 | `snacks.nvim`   | 傳統樹狀圖                  |
| `\` + `dd`       | 開啟 DevDocs                | `nvim-devdocs`  |                             |
| `\` + `dt`       | 切換 DevDocs 視窗           | `nvim-devdocs`  |                             |
| `<Space><Space>` | **Quick Command Menu**      | `snacks.nvim`   | 自定義的超級選單            |

## 🧠 LSP 與 程式碼智慧 (LSP & Code Intel)

`Dressing` 專注於選單 (Select)，讓 Code Action 變漂亮。

| **按鍵組合**     | **功能**                  | **來源插件**     | **備註**                   |
| :--------------- | :------------------------ | :--------------- | :------------------------- |
| `gd`             | 跳轉定義 (Definition)     | `lsp/common.lua` | 透過 Snacks                |
| `gr`             | 查找引用 (References)     | `lsp/common.lua` | 透過 Snacks                |
| `gi`             | 跳轉實作 (Implementation) | `lsp/common.lua` |                            |
| `gD`             | 跳轉宣告 (Declaration)    | `lsp/common.lua` |                            |
| `gh`             | 懸浮說明 (Hover)          | `lsp/common.lua` | 支援 Markdown              |
| `gl`             | 文件大綱 (Outline)        | `lsp/common.lua` | 透過 Snacks                |
| `go`             | 診斷列表 (Diagnostics)    | `lsp/common.lua` | 透過 Snacks                |
| `g[` / `g]`      | 上一個 / 下一個 診斷點    | `lsp/common.lua` |                            |
| `\` + `rn`       | 變數重命名 (Rename)       | `lsp/common.lua` | 由 Snacks Input 接管 UI    |
| `\` + `xa`       | 程式碼行動 (Code Action)  | `lsp/common.lua` | 由 Dressing Select 接管 UI |
| `\` + `l`        | 手動觸發 Linting          | `nvim-lint`      | 平常會自動跑               |
| `<Leader>` + `=` | **格式化程式碼 (Format)** | `conform.nvim`   | 拯救混亂縮排               |
| `gcc`            | 註解當前行                | `ts-comments`    | 支援 Vue/React 混合        |
| `gm`             | **開啟/隱藏 終端機**      | `snacks.nvim`    | 雙擊 Esc 關閉              |

## 🔭 搜尋與導航 (Search & Navigation)

| **按鍵組合**     | **功能**                   | **來源插件**    | **備註**              |
| :--------------- | :------------------------- | :-------------- | :-------------------- |
| `\` + `ff`       | 找檔案 (Find Files)        | `snacks.nvim `  |                       |
| `\` + `fg`       | 全文搜尋 (Live Grep)       | `snacks.nvim `  |                       |
| `\` + `fb`       | 找 Buffer                  | `snacks.nvim `  |                       |
| `\` + `fh`       | 找 Help Tags               | `snacks.nvim `  |                       |
| `\` + `fd`       | 找診斷 (Diagnostics)       | `snacks.nvim `  |                       |
| `\` + `fq`       | 找 Config 文件             | `snacks.nvim `  | `~/.config/nvim/docs` |
| `\` + `sr`       | **專案搜尋替換** (GrugFar) | `grug-far.nvim` | 強大的取代工具        |
| `\` + `sw`       | 搜尋游標下單字 (GrugFar)   | `grug-far.nvim` | 支援 Visual Mode      |
| `\\` + `w` / `b` | Flash Jump Word (前/後)    | `flash.nvim`    | 快速跳轉單字          |
| `\\` + `l` / `h` | Flash Jump Char (前/後)    | `flash.nvim`    | 快速跳轉字元          |
| `\\` + `r`       | Flash Remote               | `flash.nvim`    | 跨視窗跳轉            |

## 📑 Buffer 與 標記 (Buffer & Marks)

| **按鍵組合**      | **功能**                | **來源插件**      | **備註** |
| :---------------- | :---------------------- | :---------------- | :------- |
| `<C-h>` / `<C-l>` | 上一個 / 下一個 Buffer  | `bufferline.nvim` |          |
| `<C-x>`           | 關閉 Buffer             | `bufferline.nvim` |          |
| `\\` + `1` ~ `0`  | 跳轉到第 1~10 個 Buffer | `bufferline.nvim` |          |
| `\` + `ba`        | 加入書籤 (Harpoon Add)  | `harpoon`         |          |
| `\` + `bl`        | 書籤清單 (Harpoon List) | `harpoon`         |          |
| `\` + `b1` ~ `b4` | 跳轉書籤 1~4            | `harpoon`         |          |
| `m,`              | 設置下一個可用標記      | `marks.nvim`      |          |
| `dmx`             | 刪除標記 x              | `marks.nvim`      |          |

## 🦀 Rust & Go 專屬區 (Lang Specific)

### 🐹 Go (Gopher.nvim)

_只在 Go 檔案生效_

| **按鍵組合** | **功能**            | **說明**           |
| :----------- | :------------------ | :----------------- |
| `\` + `gs`   | Add JSON Tags       | 自動加 struct tags |
| `\` + `gS`   | Remove JSON Tags    | 移除 tags          |
| `\` + `ge`   | Add `if err != nil` | 寫 Go 必備         |
| `\` + `rr`   | **Go Run**          | 透過 Snacks        |
| `\` + `rb`   | **Go Build**        | 透過 Snacks        |

### 🦀 Rust (Rustaceanvim)

_只在 Rust 檔案生效_

| **按鍵組合** | **功能**         | **說明**          |
| :----------- | :--------------- | :---------------- |
| `\` + `ca`   | Rust Code Action | 群組化的 Action   |
| `\` + `rd`   | Debuggables      | 選擇可除錯項目    |
| `\` + `rr`   | **Runnables**    | 執行 Cargo run 等 |
| `\` + `rm`   | Expand Macro     | 展開巨集 (學習用) |
| `\` + `rh`   | Hover Actions    | 更強大的懸浮      |

### 📊 R (R.nvim)

_只在 R 檔案生效_

| **按鍵組合** | **功能**    | **說明**             |
| :----------- | :---------- | :------------------- |
| `\` + `rf`   | Enable Env  | 啟動R環境            |
| `<Enter>`    | Send Line   | 發送當前行到 Console |
| `\` + `ro`   | Variables   | 開啟變數視窗         |
| `\` + `rC`   | Clear Env   | 清空變數             |
| `\` + `gg`   | Head Object | 檢查變數前 15 行     |

## 🐞 除錯與測試 (Debug & Test)

| **按鍵組合**       | **功能**                     | **來源插件**  |
| :----------------- | :--------------------------- | :------------ |
| `F5`               | 開始 / 繼續 (Continue)       | `nvim-dap`    |
| `F10`              | **關閉除錯器**               | `nvim-dap`    |
| `F6` / `F7` / `F8` | Step Into / Over / Out       | `nvim-dap`    |
| `\` + `db`         | 切換斷點 (Toggle Breakpoint) | `nvim-dap`    |
| `\` + `du`         | 開關 DAP UI                  | `nvim-dap`    |
| `\` + `tdv`        | 查看變數 (Variables)         | `Snacks.nvim` |
| `\` + `tt`         | 測試游標下的函數 (Nearest)   | `neotest`     |
| `\` + `tf`         | 測試當前檔案 (File)          | `neotest`     |
| `\` + `ts`         | 測試摘要面板 (Summary)       | `neotest`     |
| `\` + `tw`         | 開啟測試監控 (Watch)         | `neotest`     |

## 📝 其他工具 (Git, Markdown, etc.)

| **按鍵組合**      | **功能**                 | **來源插件**       | **備註**              |
| :---------------- | :----------------------- | :----------------- | :-------------------- |
| `]g` / `[g`       | 下一個 / 上一個 Git Hunk | `gitsigns`         |                       |
| `<Space>` + `gp`  | 預覽 Git Hunk            | `gitsigns`         |                       |
| `<Space>` + `gb`  | Git Blame Line           | `gitsigns`         |                       |
| `\` + `do` / `de` | 開啟 / 關閉 DiffView     | `diffview`         |                       |
| `\` + `mp`        | Markdown Preview         | `markdown-preview` |                       |
| `\` + `fv`        | **編碼偵測/轉換**        | `fencview`         | 唯一的 Vimscript 遺產 |
| `ga` + `s`        | 文字對齊                 | `mini.align`       |                       |
| `\` + `fp`        | 剪貼簿歷史               | `snacks.nvim`      |                       |
| `zF` / `zf`       | 開啟 / 關閉 所有折疊     | `nvim-ufo`         |                       |
