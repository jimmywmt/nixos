# ==============================================================================
# ❄️ National Kaohsiung University of Science and Technology - Workstation Config
# 🛠️ Home Manager Configuration (home.nix)
# ==============================================================================

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ----------------------------------------------------------------------------
  # 👤 SECTION 1: 使用者基礎身分與環境狀態宣告
  # ----------------------------------------------------------------------------
  home.username = "wmt";
  home.homeDirectory = "/home/wmt";
  home.stateVersion = "26.05";

  # ----------------------------------------------------------------------------
  # ⌨️ SECTION 2: 全域環境變數與 PATH 對齊
  # ----------------------------------------------------------------------------
  home.sessionVariables = {
    # 🎯 現代 Wayland / GTK4 已廢棄 GTK_IM_MODULE，強行注入容易造成 GTK4 程式異常或無法輸入
    # 原生 Wayland 程式由 text-input 協議直接對接 Fcitx5；XWayland 程式則依賴 XMODIFIERS
    # GTK_IM_MODULE = "fcitx";
    # QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    IMSETTINGS_MODULE = "fcitx";
    NH_FLAKE = "$HOME/.config/nixos";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  # ----------------------------------------------------------------------------
  # 📦 SECTION 3: 個人軟體包依賴代管 (User-level Packages)
  # ----------------------------------------------------------------------------
  home.packages =
    with pkgs;
    let
      # 1. 宣告包好套件的 R 核心
      myR = rWrapper.override {
        packages = with rPackages; [
          tidyverse # 已包含 ggplot2, dplyr, readr, tidyr, purrr 等核心套件
          devtools # 套件開發工具
          rmarkdown # 動態報告輸出
          knitr # 報告編織工具
          styler # 提供 styler 以供 RFormat 呼叫
          languageserver # 給 Neovim (nvim-lspconfig) 使用的 LSP Server
        ];
      };
      # 2. 宣告使用此 R 核心的 RStudio
      myRStudio = rstudioWrapper.override {
        packages = [ myR ];
      };

      # 3. 自訂指令：智慧區域/視窗截圖 (滑鼠移到視窗自動吸附點擊即截，拖曳則自由框選，支援 Satty 標註)
      shotArea = writeShellScriptBin "shot-area" ''
        WINDOWS=$(${pkgs.sway}/bin/swaymsg -t get_tree 2>/dev/null | ${pkgs.jq}/bin/jq -r '.. | select(.visible? and .visible == true and (.app_id? != null or .window? != null)) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' 2>/dev/null)

        if [ -n "$WINDOWS" ]; then
          REGION=$(echo "$WINDOWS" | ${pkgs.slurp}/bin/slurp -d -c "#ca9ee6" -s "#ca9ee633" -B "#31324488")
        else
          REGION=$(${pkgs.slurp}/bin/slurp -d -c "#ca9ee6" -s "#ca9ee633")
        fi

        [ -z "$REGION" ] && exit 0

        ${pkgs.grim}/bin/grim -g "$REGION" - | ${pkgs.satty}/bin/satty \
          --filename - \
          --output-filename "$HOME/Pictures/Screenshot_%Y%m%d_%H%M%S.png" \
          --early-exit \
          --save-after-copy \
          --copy-command "${pkgs.wl-clipboard}/bin/wl-copy"
      '';

      # 4. 自訂指令：純視窗截圖 (macOS 空白鍵相機模式：強制鎖定只能點擊視窗)
      shotWindow = writeShellScriptBin "shot-window" ''
        WINDOWS=$(${pkgs.sway}/bin/swaymsg -t get_tree 2>/dev/null | ${pkgs.jq}/bin/jq -r '.. | select(.visible? and .visible == true and (.app_id? != null or .window? != null)) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' 2>/dev/null)

        if [ -n "$WINDOWS" ]; then
          REGION=$(echo "$WINDOWS" | ${pkgs.slurp}/bin/slurp -r -d -c "#ca9ee6" -s "#ca9ee633" -B "#31324488")
        else
          REGION=$(${pkgs.slurp}/bin/slurp -d -c "#ca9ee6" -s "#ca9ee633")
        fi

        [ -z "$REGION" ] && exit 0

        ${pkgs.grim}/bin/grim -g "$REGION" - | ${pkgs.satty}/bin/satty \
          --filename - \
          --output-filename "$HOME/Pictures/Screenshot_%Y%m%d_%H%M%S_win.png" \
          --early-exit \
          --save-after-copy \
          --copy-command "${pkgs.wl-clipboard}/bin/wl-copy"
      '';

      # 5. 自訂指令：全螢幕截圖
      shotFull = writeShellScriptBin "shot-full" ''
        ${pkgs.grim}/bin/grim - | ${pkgs.satty}/bin/satty \
          --filename - \
          --output-filename "$HOME/Pictures/Screenshot_%Y%m%d_%H%M%S_full.png" \
          --early-exit \
          --save-after-copy \
          --copy-command "${pkgs.wl-clipboard}/bin/wl-copy"
      '';

      # 5. 自訂指令：Zathura PDF 反向跳轉至 Neovim (SyncTeX)
      zathuraRemoteNvim = writeShellScriptBin "zathura-remote-nvim" ''
        SERVER=$(cat /tmp/curserver 2>/dev/null)
        if [ -n "$SERVER" ]; then
          nvim --server "$SERVER" --remote-send "<C-\><C-N>:e $1<CR>:$2<CR>"
        fi
      '';

      # 6. 自訂指令：歐路字典快速查詞 (支援 Walker 與終端快速查詞聯動)
      euc = writeShellScriptBin "euc" ''
        APPIMAGE="$HOME/AppImage/eudic/eudic.AppImage"
        if [ ! -f "$APPIMAGE" ]; then
          ${pkgs.libnotify}/bin/notify-send "Eudic" "找不到歐路字典 AppImage: $APPIMAGE" 2>/dev/null
          exit 1
        fi

        # 淨化環境變數，以 XCB/XWayland 通道運行 Qt 5
        export QT_QPA_PLATFORM=xcb
        unset QT_PLUGIN_PATH

        WORD="$*"
        # 去除 URI 前綴 (如 eudic:// 或 dict://)
        WORD="''${WORD#eudic://}"
        WORD="''${WORD#dict://}"
        # 處理 URL 編碼 (空格 %20 或 +)
        WORD="''${WORD//+/ }"
        WORD=$(printf '%b' "''${WORD//%/\\x}")

        if [ -z "$WORD" ]; then
          nohup ${pkgs.appimage-run}/bin/appimage-run "$APPIMAGE" >/dev/null 2>&1 &
        else
          nohup ${pkgs.appimage-run}/bin/appimage-run "$APPIMAGE" --word "$WORD" >/dev/null 2>&1 &
        fi

        # 在 Sway 環境下聚焦歐路詞典視窗
        if command -v swaymsg >/dev/null 2>&1; then
          (
            sleep 0.4
            swaymsg '[class="(?i)eudic"] focus' >/dev/null 2>&1
          ) &
        fi
      '';

      # 7. 自訂指令：Thunar 右鍵在此開啟 Ghostty 終端機
      thunarOpenTerminal = writeShellScriptBin "thunar-open-terminal" ''
        if [ -d "$1" ]; then
          DIR="$1"
        elif [ -d "$2" ]; then
          DIR="$2"
        else
          DIR="$HOME"
        fi
        exec ghostty --working-directory="$DIR"
      '';

      # 8. 自訂指令：Terminal 與檔案管理器雙向跳轉 (Ghostty ⇄ Thunar)
      jumpFolder = writeShellScriptBin "jump-folder" ''
        FOCUSED_JSON=$(${pkgs.sway}/bin/swaymsg -t get_tree 2>/dev/null | ${pkgs.jq}/bin/jq -r '.. | select(.focused? == true) | {app_id: .app_id, pid: .pid, name: .name}')
        APP_ID=$(echo "$FOCUSED_JSON" | ${pkgs.jq}/bin/jq -r '.app_id // empty')
        PID=$(echo "$FOCUSED_JSON" | ${pkgs.jq}/bin/jq -r '.pid // empty')
        TITLE=$(echo "$FOCUSED_JSON" | ${pkgs.jq}/bin/jq -r '.name // empty')

        TARGET_DIR=""

        if [ "$APP_ID" = "com.mitchellh.ghostty" ]; then
          # 當前在 Ghostty：找尋 Shell 或其子行程的當前工作目錄
          SHELL_PID=$(${pkgs.procps}/bin/pgrep -P "$PID" 2>/dev/null | tail -n 1)
          if [ -n "$SHELL_PID" ]; then
            DEEPEST_PID=$(${pkgs.procps}/bin/pgrep -P "$SHELL_PID" 2>/dev/null | tail -n 1)
            if [ -n "$DEEPEST_PID" ] && [ -d "/proc/$DEEPEST_PID/cwd" ]; then
              TARGET_DIR=$(readlink -f "/proc/$DEEPEST_PID/cwd" 2>/dev/null)
            elif [ -d "/proc/$SHELL_PID/cwd" ]; then
              TARGET_DIR=$(readlink -f "/proc/$SHELL_PID/cwd" 2>/dev/null)
            fi
          fi
          if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
            if [ -d "/proc/$PID/cwd" ]; then
              TARGET_DIR=$(readlink -f "/proc/$PID/cwd" 2>/dev/null)
            else
              TARGET_DIR="$HOME"
            fi
          fi
          thunar "$TARGET_DIR" >/dev/null 2>&1 &

        elif [ "$APP_ID" = "thunar" ]; then
          # 當前在 Thunar：從視窗標題抓取路徑
          CLEAN_TITLE="''${TITLE% - *}"
          if [ -d "$TITLE" ]; then
            TARGET_DIR="$TITLE"
          elif [ -d "$CLEAN_TITLE" ]; then
            TARGET_DIR="$CLEAN_TITLE"
          elif [ -d "$HOME/$CLEAN_TITLE" ]; then
            TARGET_DIR="$HOME/$CLEAN_TITLE"
          else
            TARGET_DIR="$HOME"
          fi
          ghostty --working-directory="$TARGET_DIR" >/dev/null 2>&1 &

        else
          # 非 Ghostty / Thunar 時的預設行為（開啟家目錄之檔案管理器）
          thunar "$HOME" >/dev/null 2>&1 &
        fi
      '';
    in
    [
      # ========================================================================
      # 🦀 1. 現代化 Rust CLI 刀組 & 終端工作流 (Rewrite It In Rust)
      # ========================================================================
      ripgrep # 宇宙最快純文字搜尋引擎
      fd # 簡單、快速的尋找工具
      dust # 樹狀圖顯示硬碟佔用
      procs # 現代化進程檢視器
      tokei # 程式碼行數與語言佔比統計
      hyperfine # 命令行基準測試神器
      delta # 帶有語法高亮與行號的極美 Git Diff 工具
      tmux # 終端機複用器
      xdg-ninja # 🥷 檢查家目錄違規設定檔並給予 XDG 標準遷移建議
      nix-tree # 🌳 互動式 TUI 探索 Nix 依賴樹、套件佔用與 why-depends
      nix-du # 視覺化分析 Nix GC Roots 與磁碟佔用
      sd # 🦀 直覺極速的現代化文字替換工具 (取代 sed)
      xh # 🦀 友善好用且自帶高亮的現代 HTTP/REST 請求工具 (取代 curl/httpie)
      nix-output-monitor # ❄️ nom: Nix 建構過程彩色動態樹狀圖 (與 nh 深度整合)
      ripdrag # Linux 桌面的 Yoink 替代

      # ========================================================================
      # 📊 2. 數據分析、試算表與計算引擎 (Data & Calculation Tools)
      # ========================================================================
      sc-im # 終端機純文字試算表 (Vim 鍵位)
      (pkgs.visidata.overrideAttrs (oldAttrs: {
        propagatedBuildInputs =
          oldAttrs.propagatedBuildInputs
          ++ (with pkgs.python3Packages; [
            pandas # 數據分析與高級計算
            openpyxl # Excel 讀寫支援
            zstandard # zstd 壓縮格式
          ]);
      })) # 終端機神級數據探索工具 (CSV/Excel/JSON)
      libqalculate # 終端機超強計算機 (qalc)
      qalculate-gtk # 圖形介面計算機 (Qalculate!)
      gcalcli # Google Calendar CLI 工具

      # ========================================================================
      # 🚀 3. 程式語言、編譯工具與學術環境 (Dev Toolchains & Academic)
      # ========================================================================
      gcc # GNU 語言編譯器套件 (C/C++)
      gnumake # 傳統 GNU Make 編譯工具
      lazygit # 終端機裡的 Git 圖形化整合介面
      neovide # nvim 的 GUI 前端
      bubblewrap # 輕量沙箱工具
      tectonic # 基於 Rust 的自給自足式 LaTeX 引擎

      # 多語言編譯器與工具鏈
      rustc # Rust 核心編譯器
      cargo # Rust 套件管理器
      rustfmt # Rust 程式碼格式化工具
      clippy # Rust 靜態代碼分析工具
      go # Go 程式語言編譯器與工具鏈
      python3 # Python 3 執行期環境
      uv # 🦀 極速 Rust 打造的 Python 套件與環境管理器
      nodejs-slim # Node.js 執行期環境 (僅含 node，不含 npm/npx)
      pnpm # 現代化、極速且節省空間的 Node.js 包管理器
      temurin-bin-21 # Java 21 執行期環境 (JDK)
      gradle # Java 建構工具
      lua5_4 # Lua 5.4 解譯器
      myR # 👈 提供 Terminal 裡的 `R` 與 `Rscript` 指令 (含 tidyverse/LSP)
      myRStudio # 👈 提供 RStudio 圖形介面
      nixd # ❄️ Nix 語言 LSP (支援 NixOS/HM Option 補全與文檔)
      nixfmt # ❄️ Nix 官方 RFC 166 程式碼格式化標準
      alejandra # ❄️ 備用 Nix 極速代碼格式化器

      # ========================================================================
      # 🖥️ 4. Wayland / Sway 視窗管理器周邊 (Wayland Desktop Infrastructure)
      # ========================================================================
      cliphist # 專為 Wayland 打造的極輕量 SQLite 剪貼簿後端
      wl-clipboard # Wayland 底層剪貼簿後端 (wl-copy, wl-paste)
      imagemagick # 圖像處理工具 (提供 Walker / Elephant 剪貼簿圖片預覽)
      dragon-drop # 🐉 Linux 界神級暫存拖曳工具 (Yoink 核心)
      grim # Wayland 截圖工具
      slurp # Wayland 區域選取工具
      satty # 🦀 現代化 Wayland 截圖標註與打馬賽克神器
      hyprpicker # Wayland 螢幕吸管/取色器
      brightnessctl # 筆電螢幕亮度物理調度工具
      playerctl # 多媒體按鍵控制 CLI
      wlogout # 高雅 Wayland 電源選單
      swaylock # Lock 按鈕實體依賴
      swayidle # Idle 按鈕實體依賴
      sway-audio-idle-inhibit # 🔊 音訊播放時自動抑制閒置鎖屏
      nwg-drawer # 全螢幕圖形化 App 啟動抽屜
      polkit_gnome # GTK 提權彈窗代理
      swaynotificationcenter # 現代化通知中心與快捷面板 (swaync)
      networkmanagerapplet # 網路管理員托盤小圖示 (nm-applet)
      hicolor-icon-theme # 通用圖示主題
      trash-cli # CLI 安全回收桶工具
      appimage-run # AppImage 程式執行
      seahorse # 密鑰管理 GUI

      # 自訂 Wayland / 編輯器整合快捷指令
      shotArea # 📸 自訂一鍵智慧區域/視窗截圖指令
      shotWindow # 🪟 自訂純視窗截圖指令 (macOS 空白鍵相機模式)
      shotFull # 📸 自訂全螢幕截圖指令
      jq # JSON 解析工具 (供視窗幾何提取)
      zathuraRemoteNvim # 📚 Zathura 與 Neovim 反向跳轉設定
      euc # 📖 歐路字典快速查詞指令 (支援 Walker 與終端)
      thunarOpenTerminal # 📂 Thunar 右鍵選單支援 Ghostty
      jumpFolder # 🔄 Terminal 與檔案管理器雙向無縫跳轉

      # 螢幕與桌布管理
      wlr-randr # CLI 螢幕管理
      wdisplays # Sway/Wayland 專用圖形化螢幕管理面板
      awww # Wayland 動態桌布守護進程
      waypaper # 桌布選擇 GUI 前端

      # ========================================================================
      # 🔊 5. 系統硬體、藍牙與音效調度 (Hardware, Bluetooth & Audio)
      # ========================================================================
      fastfetch # 極速系統總覽
      smartmontools # 🩺 NVMe / SATA 硬碟健康狀態與壽命檢查 (smartctl)
      pciutils # 提供 lspci
      usbutils # 提供 lsusb
      cpu-x # 現代化 CPU-Z 複刻版
      hardinfo2 # 經典樹狀裝置管理員
      blueman # 藍牙管理面板與常駐系統托盤
      pavucontrol # GUI 音效主控台
      pulsemixer # TUI 終端機音量調節器
      pasystray # 系統托盤音效管理員

      # ========================================================================
      # 📁 6. 檔案管理、解壓縮與縮圖 (File Management & Archiving)
      # ========================================================================
      (thunar.override {
        thunarPlugins = [
          thunar-archive-plugin
          thunar-volman
        ];
      }) # 極輕量 GUI 檔案管理 (Thunar)
      tumbler # Thunar 的圖片縮圖生成引擎
      file-roller # 極輕量 GTK 解壓縮總管
      p7zip # 萬能的 7z 核心
      zip # 標準 zip 壓縮工具
      unzip # 解 zip 專用老將
      unrar # 物理超渡 rar 檔案
      zstd # 現代最速壓縮協議

      # ========================================================================
      # 📡 7. 網路傳輸、遠端工具與串流下載 (Network & Remote Tools)
      # ========================================================================
      aria2 # 多協定下載工具
      croc # 🐊 終端機端對端加密 P2P 快傳工具
      rclone # ☁️ 強大的本地與多雲端硬碟同步/掛載工具
      rsync # 本地檔案快速同步工具
      sshfs # 透過 SSH 掛載遠端目錄
      rustdesk-flutter # 🦀 開源遠端桌面連線工具 (按需開啟)
      localsend # 🍏 跨平台開源 AirDrop (區網 P2P 零設定傳檔與剪貼簿同步)
      nextcloud-client # Nextcloud 客戶端
      yt-dlp # MPV 4K 網址串流擴充 / 影片下載
      poppler-utils # PDF 渲染工具套件
      ffmpegthumbnailer # 影片縮圖生成器

      # ========================================================================
      # 💬 8. 即時通訊軟體區 (Instant Messaging)
      # ========================================================================
      telegram-desktop # Telegram 桌面版
      karere # WhatsApp 第三方桌面版
      wechat # 微信桌面版

      # ========================================================================
      # 📄 9. 閱讀、文書辦公與影像檢視 (Office, Readers & Media)
      # ========================================================================
      onlyoffice-desktopeditors # ONLYOFFICE 辦公套件
      kdePackages.okular # Okular 文件/PDF 閱讀器
      zathura # 極簡鍵盤導向 PDF 閱讀器
      sioyek # 📚 專為學術論文與厚重教材設計的黑科技 PDF 閱讀器 (傳送門/智慧跳轉/抗反色)
      geeqie # 經典硬派極速 ACDSee 圖片檢視器

      # ========================================================================
      # 🖨️ 10. 印表機和掃描器 (Printing & Scanning)
      # ========================================================================
      simple-scan # GNOME 家族的極簡掃描器
      system-config-printer # 傳統的 GTK3 印表機管理面板
    ];

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };

  # 🎯 自動同步並實體解開 NixOS 系統字型至家目錄（專治 ONLYOFFICE Symlink 缺陷）
  home.activation.syncNixosFonts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.local/share/fonts/nix-managed

    SYS_FONTS=""
    if [ -d /run/current-system/sw/share/X11/fonts/ ]; then
      SYS_FONTS="/run/current-system/sw/share/X11/fonts/"
    elif [ -d /usr/share/fonts/ ]; then
      SYS_FONTS="/usr/share/fonts/"
    fi

    if [ -n "$SYS_FONTS" ]; then
      # 直接使用 -aL 進行無差別實體鏡像同步，不再加脆弱的 --include/--exclude 規則
      $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -aL --delete \
        "$SYS_FONTS" "$HOME/.local/share/fonts/nix-managed/"
    fi
  '';

  # ----------------------------------------------------------------------------
  # 📚 Zathura PDF 閱讀器與 SyncTeX 反向搜尋設定
  # ----------------------------------------------------------------------------
  programs.zathura = {
    enable = true;
    options = {
      # 🎯 顯式開啟 SyncTeX 功能
      "synctex" = true;
      "synctex-editor-command" = "zathura-remote-nvim %{input} %{line}";

      # 🎨 視覺風格：Catppuccin Mocha 暗色系適配
      "font" = "JetBrainsMono Nerd Font 11";
      "default-bg" = "#1e1e2e";
      "default-fg" = "#cdd6f4";
      "statusbar-bg" = "#181825";
      "statusbar-fg" = "#cdd6f4";
      "inputbar-bg" = "#181825";
      "inputbar-fg" = "#cdd6f4";
      "completion-bg" = "#1e1e2e";
      "completion-fg" = "#cdd6f4";
      "completion-highlight-bg" = "#313244";
      "completion-highlight-fg" = "#cba6f7";
      "highlight-color" = "rgba(249, 226, 175, 0.35)"; # 一般高亮 (Catppuccin Yellow)
      "highlight-active-color" = "rgba(250, 179, 135, 0.45)"; # 當前跳轉點 (Catppuccin Peach)
      "notification-error-bg" = "#f38ba8";
      "notification-error-fg" = "#1e1e2e";
      "notification-warning-bg" = "#fab387";
      "notification-warning-fg" = "#1e1e2e";
      "notification-bg" = "#a6e3a1";
      "notification-fg" = "#1e1e2e";

      # ⚙️ 互動行為設定
      "adjust-open" = "best-fit";
      "statusbar-home-tilde" = true;
      "selection-clipboard" = "clipboard";
    };
  };

  # ----------------------------------------------------------------------------
  # 🐚 SECTION 4: Shell 與 Terminal 生態系 (Zsh, Ghostty, Starship, Zoxide)
  # ----------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # 大小寫不敏感 + 模糊比對
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

      # 補全選單高亮
      zstyle ':completion:*' menu select

      # 若存在 ~/.zshrc.local 則自動載入（不受 Home Manager 唯讀管控）
      if [ -f "$HOME/.zshrc.local" ]; then
        source "$HOME/.zshrc.local"
      fi
    '';

    shellAliases = {
      ll = "ls -l";
      g = "git";
      nr = "git add -A && nh os switch ~/.config/nixos -H \${NIX_PROFILE:-gpu-profile} && exec zsh";
      nru = "git add -A && nh os switch ~/.config/nixos -H \${NIX_PROFILE:-gpu-profile} -u && exec zsh";
      nrt = "git add -A && nh os test ~/.config/nixos -H \${NIX_PROFILE:-gpu-profile}";
      nrb = "git add -A && nh os boot ~/.config/nixos -H \${NIX_PROFILE:-gpu-profile}";
      nc = "nh clean all --keep 5";
      nxc = "sudo nix-collect-garbage --delete-old";
      nxcg = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      nxl = "sudo nixos-rebuild list-generations";
      cat = "bat";
      top = "btop";
      aria = "aria2c";
      y = "yazi";
      mn = "udisksctl mount -b";
      umn = "udisksctl unmount -b";
      poff = "udisksctl power-off -b";
      ch-clear = "cliphist wipe";
      cb2file = "wl-paste > ~/Pictures/Clip_\$(date +%Y%m%d_%H%M%S).png && echo '📸 剪貼簿圖片已存至 ~/Pictures'";
      tp = "trash-put";
      rd-start = "W=\$(basename \$(find /run/user/\$UID -maxdepth 1 -name 'wayland-[0-9]' -type s 2>/dev/null | head -n 1) 2>/dev/null); nohup env WAYLAND_DISPLAY=\${W:-wayland-1} DISPLAY=:0 rustdesk >/dev/null 2>&1 & sleep 0.5 && echo \"🦀 RustDesk 已啟動！連線 ID: \$(rustdesk --get-id 2>/dev/null)\"";
      rd-stop = "pkill -f rustdesk && echo '🛑 RustDesk 已關閉'";
      rd-id = "rustdesk --get-id";
      onlyoffice = "env QT_IM_MODULE=ibus QT_PLUGIN_PATH= XMODIFIERS=@im=fcitx onlyoffice-desktopeditors";
    };

    antidote = {
      enable = true;
      plugins = [
        "zsh-users/zsh-completions"
        "wfxr/forgit"
        "ohmyzsh/ohmyzsh path:plugins/git"
        "ohmyzsh/ohmyzsh path:plugins/sudo"
        "ohmyzsh/ohmyzsh path:plugins/extract"
        "ohmyzsh/ohmyzsh path:plugins/copypath"
        "ohmyzsh/ohmyzsh path:plugins/copyfile"
        "ohmyzsh/ohmyzsh path:lib/clipboard.zsh"
      ];
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
      theme = "Catppuccin Macchiato";
      window-padding-x = 12;
      window-padding-y = 12;
      window-decoration = false;
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$username$hostname$directory$git_branch$git_status$character";
      username = {
        show_always = true;
        style_user = "black bg:blue";
        style_root = "black bg:red";
        format = "[$user]($style)";
      };
      hostname = {
        ssh_only = false;
        style = "black bg:blue";
        format = "[@$hostname ]($style)[](blue bg:cyan)";
      };
      directory = {
        style = "black bg:cyan";
        format = "[$path ]($style)";
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = " ";
        style = "black bg:green";
        format = "[](cyan bg:green)[$symbol$branch ]($style)";
      };
      git_status = {
        style = "black bg:green";
        format = "[($all_status$ahead_behind)]($style)[](green)";
        conflicted = "💥 ";
        ahead = "⇡×$count";
        behind = "⇣×$count";
        untracked = "➕ ";
        staged = "📦 ";
        modified = "📝 ";
        deleted = "🗑️ ";
      };
      character = {
        success_symbol = "[](cyan bold green) ";
        error_symbol = "[](cyan bold red) ";
      };
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ]; # Ctrl+R 喚起 Atuin 搜尋，保留 Up 鍵快速翻閱上一條指令
    settings = {
      auto_sync = false;
      update_check = false;
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 15;
      show_preview = true;
    };
  };

  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = false;
      };
      updates = {
        auto_update = true;
      };
    };
  };

  # ----------------------------------------------------------------------------
  # 📝 SECTION 5: 開發者工具與 CLI 服務 (Neovim, Git, Yazi, Fzf...)
  # ----------------------------------------------------------------------------
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      git
      gcc
      gnumake
      ripgrep
      fd
      gopls
      rust-analyzer
      lua-language-server
      stylua
      google-java-format
      prettier
      eslint_d
      black
      isort
      clang-tools
      lldb
      tex-fmt
      vscode-extensions.vadimcn.vscode-lldb.adapter
      delve
      texlab
      harper
      jdt-language-server
      ltex-ls-plus
      marksman
      pyright
      ruff
      python3Packages.debugpy
      vscode-extensions.vscjava.vscode-java-debug
      tree-sitter
      vscode-extensions.vscjava.vscode-java-test
      vscode-langservers-extracted
      typescript-language-server
      vue-language-server
      nixd
      nixfmt
      alejandra
    ];
  };

  xdg.configFile."nvim".source = ./dotfiles/nvim;

  services.udiskie.enable = true;

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings.manager = {
      show_hidden = true;
      sort_by = "alphabetical";
      sort_dir_first = true;
    };
  };

  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--preview 'if [ -d {} ]; then fd --max-depth 1 . {}; else bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || head -100 {}; fi'"
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
      style = "numbers,changes,header";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false; # 透明背景，完美融合 Ghostty 主題
      update_ms = 1000;
      vim_keys = true; # 支援 hjkl 導航
      rounded_corners = true;
      proc_sorting = "cpu lazy";
    };
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--octal-permissions"
    ];
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jimmy Ming-Tai Wu";
        email = "wmt@wmt35.idv.tw";
      };
      gpg.format = "ssh";
    };
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
  };

  programs.jujutsu = {
    enable = true;

    # 這裡會自動生成 ~/.config/jj/config.toml
    settings = {
      user = {
        name = "Jimmy Ming-Tai Wu";
        email = "wmt@wmt35.idv.tw"; # 請替換為你的 Email
      };

      # 常用設定與 Alias
      aliases = {
        l = [
          "log"
          "-r"
          "all()"
        ];
        s = [ "status" ];
        d = [ "diff" ];
      };

      # 設定預設編輯器 (可依喜好調整，如 nvim)
      ui.editor = "nvim";
    };
  };

  # ----------------------------------------------------------------------------
  # 🖥️ SECTION 6: Wayland 視窗管理與 GTK 基礎設施 (Sway, Waybar, Mako...)
  # ----------------------------------------------------------------------------
  services.network-manager-applet.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  services.gnome-keyring.enable = true;

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
    font = {
      name = "LINE Seed TW_TTF";
      size = 10;
    };
  };

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "sway-session.target" ];
    };
    settings = [
      {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 8;
        modules-left = [
          "sway/workspaces"
          "wlr/taskbar"
        ];
        modules-right = [
          "cpu"
          "memory"
          "temperature"
          "pulseaudio"
          "tray"
          "clock"
          "custom/notification"
          "custom/power"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };
        "wlr/taskbar" = {
          format = "{icon} {title}";
          icon-size = 16;
          icon-theme = "Adwaita";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
        };
        clock = {
          format = "{:%H:%M  |  %m/%d}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        cpu = {
          format = "CPU: {usage}%";
        };
        memory = {
          format = "RAM: {used:0.1f}G";
        };
        temperature = {
          critical-threshold = 75;
          format = "{temperatureC}°C";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-muted = "󰝟 靜音";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          scroll-step = 5;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
          tooltip-format = "{desc}: {volume}%";
        };
        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "󰂚<span foreground='#f38ba8'><sup></sup></span>";
            none = "󰂚";
            dnd-notification = "󰂛<span foreground='#f38ba8'><sup></sup></span>";
            dnd-none = "󰂛";
            inhibited-notification = "󰂚<span foreground='#f38ba8'><sup></sup></span>";
            inhibited-none = "󰂚";
            dnd-inhibited-notification = "󰂛<span foreground='#f38ba8'><sup></sup></span>";
            dnd-inhibited-none = "󰂛";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };
        "custom/power" = {
          format = "⏻";
          tooltip = false;
          on-click = "wlogout";
        };
      }
    ];
    style = ''
      * {
        font-size: 13px;
        font-weight: 600;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: rgba(30, 30, 46, 0.85);
        border-bottom: 1px solid rgba(202, 158, 230, 0.25);
      }

      #workspaces button {
        padding: 0 10px; margin: 4px 2px;
        background-color: rgba(30, 30, 46, 0.7); color: #cdd6f4;
        border-radius: 6px;
      }

      #workspaces button.focused { background-color: #ca9ee6; color: #1e1e2e; }

      #clock {
        font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font";
        padding: 0 16px; margin: 4px 0;
        background-color: rgba(30, 30, 46, 0.85); color: #f2cdcd;
        border-radius: 8px; border: 1px solid rgba(255, 255, 255, 0.1);
      }

      #cpu { font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font"; color: #89b4fa; }
      #memory { font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font"; color: #a6e3a1; }
      #temperature { font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font"; color: #eba0ac; }
      #pulseaudio { font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font"; color: #fab387; padding: 0 6px; }
      #pulseaudio.muted { color: #6c7086; }
      #tray { font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font"; margin-right: 12px; padding: 0 6px; }

      #custom-notification {
        font-family: "JetBrainsMono Nerd Font";
        color: #ca9ee6;
        font-size: 14px;
        padding: 0 10px;
        margin: 4px 2px;
        background-color: rgba(202, 158, 230, 0.15);
        border-radius: 6px;
      }
      #custom-notification:hover {
        background-color: rgba(202, 158, 230, 0.3);
      }

      #custom-power {
        color: #f38ba8; font-size: 14px; padding: 0 12px; margin: 4px 4px;
        background-color: rgba(243, 139, 168, 0.15); border-radius: 6px;
      }
      #custom-power:hover { background-color: rgba(243, 139, 168, 0.3); }

      #taskbar button {
        font-family: "JetBrainsMono Nerd Font";
        font-weight: 500;
        padding: 0 10px; margin: 4px 2px;
        background-color: rgba(49, 50, 68, 0.4); color: #cdd6f4;
        border-radius: 6px;
      }
      #taskbar button.active {
        background-color: rgba(202, 158, 230, 0.4); color: #ca9ee6;
        border: 1px solid rgba(202, 158, 230, 0.6);
      }
      #taskbar button:hover { background-color: rgba(202, 158, 230, 0.2); }
    '';
  };

  # 🌀 Sway 視窗管理器配置
  wayland.windowManager.sway = {
    enable = true;

    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "walker";
      defaultWorkspace = "workspace number 1";

      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "*";
        }
      ];

      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        style = "Regular";
        size = 11.0;
      };

      keybindings =
        let
          mod = modifier;
          browser = "google-chrome";
        in
        pkgs.lib.mkOptionDefault {
          "${mod}+Return" = "exec ${terminal}";
          "${mod}+Shift+Return" = "exec ${browser}";
          "${mod}+d" = "exec ${menu}";
          "${mod}+Shift+d" = "exec nwg-drawer";
          "${mod}+Shift+q" = "kill";
          "${mod}+Shift+c" = "reload";
          "${mod}+b" = "splith";
          "${mod}+v" = "splitv";
          "${mod}+e" = "layout toggle split";
          "${mod}+w" = "layout tabbed";
          "${mod}+m" = "fullscreen toggle";
          "${mod}+Shift+space" = "floating toggle";
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          "${mod}+equal" = "exec ghostty --class=calc-pop -e qalc";
          "${mod}+c" = "exec walker -m clipboard";
          "${mod}+Tab" = "exec walker -m windows";
          "${mod}+o" = "exec jump-folder";

          "${mod}+Ctrl+Shift+4" = "exec shot-area";
          "${mod}+Ctrl+Shift+5" = "exec shot-window";
          "${mod}+Ctrl+Shift+3" = "exec shot-full";
          "${mod}+Ctrl+s" = "exec shot-area";
          "${mod}+Ctrl+w" = "exec shot-window";

          "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume raise --max-volume 100";
          "XF86AudioLowerVolume" = "exec swayosd-client --output-volume lower --max-volume 100";
          "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle";
          "XF86AudioMicMute" = "exec swayosd-client --input-volume mute-toggle";
          "XF86MonBrightnessUp" = "exec swayosd-client --brightness raise";
          "XF86MonBrightnessDown" = "exec swayosd-client --brightness lower";
          "XF86AudioPlay" = "exec swayosd-client --playerctl play-pause";
          "XF86AudioNext" = "exec swayosd-client --playerctl next";
          "XF86AudioPrev" = "exec swayosd-client --playerctl prev";
          "--release Caps_Lock" = "exec swayosd-client --caps-lock";

          "${mod}+Shift+p" = "exec hyprpicker -a";
          "${mod}+Shift+n" = "exec swaync-client -t -sw";

          "${mod}+y" = "exec ripdrag -x"; # -x: 檔案被拖出去後視窗自動退出關閉
        };

      input = {
        "type:pointer" = {
          natural_scroll = "enabled";
          accel_profile = "flat";
          pointer_accel = "0.6";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
          middle_emulation = "enabled";
        };
      };

      startup = [
        {
          command = "awww-daemon & sleep 0.5 && waypaper --restore";
          always = true;
        }
        {
          command = "blueman-applet";
          always = true;
        }
        {
          command = "nm-applet --indicator";
          always = true;
        }
        {
          command = "wl-paste --type text --watch cliphist store";
          always = true;
        }
        {
          command = "wl-paste --type image --watch cliphist store";
          always = true;
        }
        {
          command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          always = true;
        }
      ];

      bars = [ ];

      assigns = {
        "2" = [
          { app_id = "^org\\.telegram\\.desktop$"; }
          { app_id = "^io\\.github\\.tobagin\\.karere$"; }
        ];
      };

      window.commands = [
        {
          command = "floating enable";
          criteria = {
            title = "^LINE$";
          };
        }
        {
          command = "floating enable, border none, move position 85 ppt 3 ppt";
          criteria = {
            app_id = "^$";
            title = "^$";
          };
        }
        {
          command = "floating enable";
          criteria = {
            app_id = "^(org\\.telegram\\.desktop|io\\.github\\.tobagin\\.karere)$";
          };
        }
        {
          command = "floating enable";
          criteria = {
            app_id = "^org\\.gnome\\.FileRoller$";
          };
        }
        {
          command = "floating enable, resize set 1000 700, move position center";
          criteria = {
            app_id = "wdisplays";
          };
        }
        {
          command = "floating enable, resize set 1100 750, move position center";
          criteria = {
            app_id = "waypaper";
          };
        }
        {
          command = "floating enable";
          criteria = {
            title = "音量控制";
          };
        }
        {
          command = "floating enable";
          criteria = {
            title = "Qalculate!";
          };
        }
        {
          command = "floating enable, resize set 650 400, move position center";
          criteria = {
            title = "^qalc$";
          };
        }
        {
          command = "floating enable, sticky enable, resize set 400 300";
          criteria = {
            app_id = "dragon";
          };
        }
        {
          command = "floating enable, sticky enable, resize set 400 300";
          criteria = {
            title = "dragon";
          };
        }
        {
          command = "floating enable, resize set 1200 800, move position center";
          criteria = {
            app_id = "^org\\.geeqie\\.Geeqie$";
          };
        }
        {
          command = "floating enable, resize set 1200 800, move position center";
          criteria = {
            class = "^Geeqie$";
          };
        }
        {
          command = "floating enable, resize set 1200 800, move position center";
          criteria = {
            title = ".*Geeqie.*";
          };
        }
        {
          command = "floating enable, resize set 800 600, move position center";
          criteria = {
            app_id = "system-config-printer";
          };
        }
        {
          command = "floating enable, resize set 900 650, move position center";
          criteria = {
            app_id = "simple-scan";
          };
        }
        {
          command = "floating enable";
          criteria = {
            title = "^R Graphics";
          };
        }
        {
          command = "floating enable";
          criteria = {
            app_id = "^rustdesk$";
          };
        }
        {
          command = "floating enable, resize set 1100 750, move position center";
          criteria = {
            app_id = "(com\\.github\\.wwmm\\.easyeffects|easyeffects)";
          };
        }

        # 🎯 自然人憑證 / HiPKI 簽章元件彈窗浮動規則 (避免 61161 簽核與憑證驗證畫面平鋪佔滿螢幕)
        {
          command = "floating enable, resize set 450 350, move position center";
          criteria = {
            title = ".*(61161|popupForm|ChtPopupForm|CMCPopForm).*";
          };
        }

        # 🎯 Steam 視窗浮動規則 (避免好友名單、聊天室、設定等次級彈窗破壞平鋪版面)
        {
          command = "floating enable";
          criteria = {
            class = "^Steam$";
            title = "^(Friends List|Steam - News|Settings|好友名單|設定|Screenshot Uploader|Steam Guard|登入|Compact Mode).*";
          };
        }
        {
          command = "floating enable";
          criteria = {
            class = "^Steam$";
            title = ".* - (Chat|Properties|內容)";
          };
        }

        # 🎮 遊戲全螢幕時禁止自動鎖屏休眠 (手把玩遊戲不黑屏)
        {
          command = "inhibit_idle fullscreen";
          criteria = {
            class = "^steam_app_";
          };
        }

        # ⚡ 壓榨最低輸入延遲 (在螢幕刷新前最後 1 毫秒才繪製畫面)
        {
          command = "max_render_time 1";
          criteria = {
            class = "^steam_app_";
          };
        }

        # 📸 截圖標註神器 Satty 預設居中浮動
        {
          command = "floating enable, move position center";
          criteria = {
            app_id = "^(com\\.gabm\\.satty|satty)$";
          };
        }

        # 🍏 LocalSend 跨裝置傳檔預設居中浮動
        {
          command = "floating enable, resize set 950 700, move position center";
          criteria = {
            app_id = "(localsend_app|localsend|org.localsend.localsend_app)";
          };
        }

        # 🍷 Protontricks / Winetricks GUI 彈窗預設居中浮動
        {
          command = "floating enable, move position center";
          criteria = {
            app_id = "^(protontricks|winetricks)$";
          };
        }

        # 🚀 Walker 啟動器浮動與居中規則（確保在 Sway 下獲取絕對焦點）
        {
          command = "floating enable, border none, move position center";
          criteria = {
            app_id = "^(dev\\.benz\\.walker|walker)$";
          };
        }

        # 📖 歐路詞典浮動與居中規則
        {
          command = "floating enable, move position center";
          criteria = {
            class = "^(?i)eudic$";
          };
        }

        # 🐉 Yoink 體驗：ripdrag 拖放暫存架規則 (全域浮動、跨桌面釘選、靠右吸附)
        {
          command = "floating enable, sticky enable, resize set 320 240, move position 100 ppt 50 ppt, move left 340, move up 120";
          criteria = {
            app_id = "^(ripdrag|org\\.ripdrag\\.ripdrag)$";
          };
        }
      ];
    };
    extraConfig = ''
      no_focus [app_id="^$" title="^$"]
      output * adaptive_sync on
    '';
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      sway = {
        default = [
          "wlr"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
  };

  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "user";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 8;
      timeout-low = 4;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 380;
      control-center-height = 600;
      notification-window-width = 380;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      text-empty = "目前沒有任何通知";
      widgets = [
        "title"
        "dnd"
        "mpris"
        "volume"
        "notifications"
      ];
      widget-config = {
        title = {
          text = "通知中心";
          clear-all-button = true;
          button-text = "全部清除";
        };
        dnd = {
          text = "勿擾模式";
        };
        mpris = {
          image-size = 80;
          image-radius = 10;
        };
        volume = {
          label = "󰕾";
          show-per-app = true;
          show-per-app-icon = true;
          show-per-app-label = true;
          empty-list-label = "無播放中的音訊";
        };
        notifications = {
          vexpand = true;
        };
      };
    };
    style = ''
      * {
        font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font", sans-serif;
      }
      .control-center {
        background: rgba(30, 30, 46, 0.95);
        border: 2px solid rgba(202, 158, 230, 0.4);
        border-radius: 12px;
        color: #cdd6f4;
        padding: 14px;
      }
      .notification-row .notification-background .notification {
        background: rgba(49, 50, 68, 0.85);
        border: 1px solid rgba(202, 158, 230, 0.3);
        border-radius: 10px;
        color: #cdd6f4;
        padding: 10px;
        margin: 6px 0;
      }
      .notification-row .notification-background .notification:hover {
        background: rgba(69, 71, 90, 0.95);
      }
      .widget-title {
        color: #ca9ee6;
        font-size: 1.1rem;
        font-weight: 700;
        margin: 6px 10px;
      }
      .widget-title button {
        background: rgba(49, 50, 68, 0.6);
        border-radius: 8px;
        color: #cdd6f4;
        padding: 4px 10px;
        border: 1px solid rgba(202, 158, 230, 0.2);
      }
      .widget-title button:hover {
        background: rgba(202, 158, 230, 0.3);
        color: #ca9ee6;
      }
      .widget-dnd {
        background: rgba(49, 50, 68, 0.4);
        border-radius: 8px;
        padding: 8px 12px;
        margin: 8px 0;
        color: #cdd6f4;
      }
      .widget-dnd switch:checked {
        background: #ca9ee6;
      }
      .widget-mpris {
        background: rgba(49, 50, 68, 0.4);
        border-radius: 10px;
        padding: 10px;
        margin: 8px 0;
        color: #cdd6f4;
      }
      .widget-volume {
        background: rgba(49, 50, 68, 0.4);
        border-radius: 10px;
        padding: 10px 14px;
        margin: 8px 0;
        color: #cdd6f4;
      }
      .widget-volume > box > label {
        color: #ca9ee6;
        font-size: 1.1rem;
        margin-right: 10px;
      }
      .widget-volume scale highlight {
        background: #ca9ee6;
        border-radius: 4px;
      }
      .widget-volume scale trough {
        background: rgba(69, 71, 90, 0.6);
        border-radius: 4px;
        min-height: 8px;
      }
      .per-app-volume {
        background: rgba(30, 30, 46, 0.6);
        border-radius: 8px;
        padding: 6px 10px;
        margin: 4px 0;
      }
    '';
  };

  services.swayosd = {
    enable = true;
  };

  services.easyeffects = {
    enable = true;
  };

  xdg.configFile."nwg-drawer/drawer.css".text = ''
    window {
      background-color: rgba(36, 39, 58, 0.88);
      color: #cad3f5;
      font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font", sans-serif;
    }

    entry {
      background-color: rgba(49, 50, 68, 0.5);
      border: 1px solid rgba(202, 158, 230, 0.3);
      border-radius: 8px;
      color: #cdd6f4;
      padding: 6px 10px;
    }
    entry:focus {
      border-color: #ca9ee6;
    }

    #category-button {
      color: #b8c0e0;
      border: none;
      background: transparent;
      padding: 4px 10px;
    }
    #category-button:checked {
      background-color: rgba(202, 158, 230, 0.3);
      color: #ca9ee6;
      border-radius: 6px;
    }

    #app-button {
      color: #cdd6f4;
      padding: 12px;
      border-radius: 8px;
    }
    #app-button:hover {
      background-color: rgba(255, 255, 255, 0.08);
    }
  '';

  xdg.configFile."satty/config.toml".text = ''
    [general]
    fullscreen = false
    early-exit = true
    save-after-copy = true
    copy-command = "${pkgs.wl-clipboard}/bin/wl-copy"
    output-filename = "$HOME/Pictures/Screenshot_%Y%m%d_%H%M%S.png"
    initial-tool = "brush"
    corner-roundness = 8
    default-hide-toolbars = false
    primary-highlighter = "block"

    [font]
    family = "LINE Seed TW_TTF"
    style = "Bold"
  '';

  services.wlsunset = {
    enable = true;
    sunrise = "06:30";
    sunset = "18:30";
    temperature = {
      day = 6500;
      night = 4000;
    };
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f -c 11111b";
      }
    ];
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f -c 11111b";
      lock = "${pkgs.swaylock}/bin/swaylock -f -c 11111b";
    };
  };

  # 🔊 音訊播放時自動抑制閒置鎖定與螢幕休眠 (YouTube / 音樂 / 線上會議防黑屏)
  systemd.user.services.sway-audio-idle-inhibit = {
    Unit = {
      Description = "Inhibit swayidle while audio is playing";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ----------------------------------------------------------------------------
  # 🚀 SECTION 7: Launcher 與電源選單 (Walker, Elephant & Wlogout)
  # ----------------------------------------------------------------------------
  services.elephant = {
    enable = true;
  };

  # 讓 Walker 在未輸入任何字串時，優先將最近/常用啟動過的應用程式排在上方（依使用歷史加權）
  xdg.configFile."elephant/desktopapplications.toml".text = ''
    history = true
    history_when_empty = true
  '';

  # 🔍 設定 Elephant Websearch 提供者支援 euc 前綴查詞 (在 Walker 輸入 euc <單字> 即可直接查詞)
  xdg.configFile."elephant/websearch.toml".text = ''
    command = "xdg-open"

    [[entries]]
    default = true
    name = "Google"
    url = "https://www.google.com/search?q=%TERM%"

    [[entries]]
    name = "歐路字典"
    prefix = "euc "
    url = "eudic://%TERM%"
    icon = "/home/wmt/AppImage/eudic/icon.png"
  '';

  services.walker = {
    enable = true;
    systemd.enable = true;
    enableElephantIntegration = true;
    settings = {
      force_keyboard_focus = true;
      close_when_open = true;
      click_to_close = true;
      as_window = true;
      single_click_activation = true;
      exact_search_prefix = "'";
      theme = "default";

      shell = {
        exclusive_zone = -1;
        layer = "overlay";
        anchor_top = true;
        anchor_bottom = true;
        anchor_left = true;
        anchor_right = true;
      };

      placeholders = {
        "default" = {
          input = "Search...";
          list = "No Results";
        };
      };

      providers = {
        default = [
          "desktopapplications"
          "calc"
          "runner"
          "websearch"
        ];
        empty = [ "desktopapplications" ];
        max_results = 50;
      };

      # ⌨️ Vim 導航指法：支援 Ctrl + j / Ctrl + k 上下移動選取項目
      keybinds = {
        next = [
          "Down"
          "ctrl j"
        ];
        previous = [
          "Up"
          "ctrl k"
        ];
        down = [
          "Down"
          "ctrl j"
        ];
        up = [
          "Up"
          "ctrl k"
        ];
      };
    };
  };

  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "swaylock -f -c 11111b";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "swaymsg exit";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "p";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];
    style = ''
      * { background-image: none; box-shadow: none; font-family: "LINE Seed TW_TTF", sans-serif; }
      window { background-color: rgba(30, 30, 46, 0.85); }
      button, button:focus {
        background-color: rgba(49, 50, 68, 0.5); color: #cdd6f4;
        border: 2px solid rgba(202, 158, 230, 0.2); border-radius: 12px;
        margin: 15px; background-repeat: no-repeat; background-position: center;
        background-size: 25%; transition: all 0.2s ease-in-out; outline: none;
      }
      button:active, button:hover { background-color: rgba(202, 158, 230, 0.3); border-color: #ca9ee6; color: #1e1e2e; }
      #lock { background-image: url("${pkgs.wlogout}/share/wlogout/icons/lock.png"); }
      #logout { background-image: url("${pkgs.wlogout}/share/wlogout/icons/logout.png"); }
      #suspend { background-image: url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"); }
      #hibernate { background-image: url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"); }
      #shutdown { background-image: url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"); }
      #reboot { background-image: url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"); }
    '';
  };

  # ----------------------------------------------------------------------------
  # ⌨️ SECTION 8: 輸入法框架與特化軟體啟動補丁 (Fcitx5 & WeChat)
  # ----------------------------------------------------------------------------
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        kdePackages.fcitx5-qt
        libsForQt5.fcitx5-qt
        fcitx5-rime
        fcitx5-gtk
      ];
    };
  };

  # 🎯 宣告式覆寫 WeChat Desktop 捷徑 (綁定 XWayland + XCB 通道)
  xdg.desktopEntries.wechat = {
    name = "WeChat";
    exec = "env QT_QPA_PLATFORM=xcb QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx wechat %U";
    icon = "wechat";
    terminal = false;
    type = "Application";
    categories = [
      "Network"
      "InstantMessaging"
    ];
  };

  # 📖 宣告式歐路詞典 (Eudic) 捷徑與 URI Scheme 處理器
  xdg.desktopEntries.eudic = {
    name = "eudic";
    comment = "歐陸字典";
    exec = "euc %u";
    icon = "/home/wmt/AppImage/eudic/icon.png";
    terminal = false;
    type = "Application";
    categories = [
      "Utility"
      "Education"
      "Dictionary"
    ];
    mimeType = [ "x-scheme-handler/eudic" ];
  };

  # 📑 宣告式覆寫 ONLYOFFICE 捷徑 (導向 IBus 通道對接 Fcitx5，繞過缺少 Qt5 fcitx 插件問題)
  xdg.desktopEntries.onlyoffice-desktopeditors = {
    name = "ONLYOFFICE";
    genericName = "Document Editor";
    comment = "Edit office documents";
    exec = "env QT_IM_MODULE=ibus QT_PLUGIN_PATH= XMODIFIERS=@im=fcitx onlyoffice-desktopeditors %U";
    icon = "onlyoffice-desktopeditors";
    terminal = false;
    type = "Application";
    categories = [
      "Office"
      "WordProcessor"
      "Spreadsheet"
      "Presentation"
    ];
    mimeType = [
      "application/msword"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.ms-excel"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.ms-powerpoint"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/pdf"
    ];
    settings = {
      StartupWMClass = "ONLYOFFICE";
    };
  };

  # ----------------------------------------------------------------------------
  # 📝 SECTION 9: 全域代碼與協定規範 (EditorConfig, SSH, MIME & MPV)
  # ----------------------------------------------------------------------------
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        root = true;
        insert_final_newline = true;
        charset = "utf-8";
        trim_trailing_whitespace = true;
        indent_style = "space";
        indent_size = 2;
      };
      "{Makefile,go.mod,go.sum,*.go,.gitmodules,*.lua}" = {
        indent_style = "tab";
        indent_size = 4;
      };
      "*.{py,js}" = {
        indent_size = 4;
      };
      "*.swift" = {
        indent_size = 4;
      };
      "*.rs" = {
        indent_size = 4;
      };
      "*.java" = {
        indent_size = 2;
      };
      "*.md" = {
        indent_size = 4;
        trim_trailing_whitespace = false;
        eclint_indent_style = "unset";
      };
      "*.{c++,cc,cpp,cxx,h,h++,hh,hpp,hxx,inl,ipp,tlh,tli}" = {
        cpp_indent_case_contents_when_block = true;
        cpp_new_line_before_open_brace_namespace = "same_line";
      };
      "*.slint" = {
        indent_size = 4;
      };
      "Dockerfile" = {
        indent_size = 4;
      };
    };
  };

  programs.ssh = {
    enableDefaultConfig = false;
    settings."*" = {
      Compression = "yes";
      ServerAliveInterval = 60;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.kde.okular.desktop" ];
      "inode/directory" = [ "thunar.desktop" ];

      # 🌐 預設網頁瀏覽器與 Protocol 處理器
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
      "x-scheme-handler/eudic" = [ "eudic.desktop" ];

      # 🖼️ 預設圖片瀏覽器：Geeqie
      "image/jpeg" = [ "org.geeqie.Geeqie.desktop" ];
      "image/png" = [ "org.geeqie.Geeqie.desktop" ];
      "image/gif" = [ "org.geeqie.Geeqie.desktop" ];
      "image/webp" = [ "org.geeqie.Geeqie.desktop" ];
      "image/tiff" = [ "org.geeqie.Geeqie.desktop" ];
      "image/bmp" = [ "org.geeqie.Geeqie.desktop" ];
      "image/svg+xml" = [ "org.geeqie.Geeqie.desktop" ];
      "image/vnd.microsoft.icon" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-icon" = [ "org.geeqie.Geeqie.desktop" ];

      "image/avif" = [ "org.geeqie.Geeqie.desktop" ];
      "image/heif" = [ "org.geeqie.Geeqie.desktop" ];
      "image/heic" = [ "org.geeqie.Geeqie.desktop" ];
      "image/jxl" = [ "org.geeqie.Geeqie.desktop" ];

      "image/x-tga" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-pcx" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-portable-anymap" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-portable-bitmap" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-portable-pixmap" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-xbitmap" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-xpixmap" = [ "org.geeqie.Geeqie.desktop" ];

      "image/x-canon-cr2" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-canon-crw" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-nikon-nef" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-sony-arw" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-adobe-dng" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-olympus-orf" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-fuji-raf" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-panasonic-raw" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-pentax-pef" = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-dcraw" = [ "org.geeqie.Geeqie.desktop" ];
    };
  };

  # 🙈 覆蓋並隱藏重複的 Google Chrome 捷徑
  xdg.desktopEntries."com.google.Chrome" = {
    name = "Google Chrome";
    noDisplay = true;
  };

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      uosc # 👑 現代化動態 UI / 雙語字幕選單 / 控制面板
      thumbfast # 📸 懸停時間軸時顯示影片實體縮圖
      mpris # 🎵 打通 D-Bus 供 Waybar 媒體控制
    ];

    config = {
      vo = "gpu-next";
      gpu-context = "wayland";
      hwdec = "auto-safe";
      osd-bar = "no";
      border = "no";
      slang = "cht,zh-TW,zh,eng";
      alang = "jpn,eng,zh";
      sub-auto = "fuzzy";
      keep-open = "yes";
    };

    scriptOpts = {
      uosc = {
        timeline_style = "bar";
        volume_control = "hover";
        autohide_delay = 2000;
      };
    };
  };

  # ----------------------------------------------------------------------------
  # 📂 SECTION 10: 檔案管理器與終端雙向聯動 (Thunar & Ghostty Integration)
  # ----------------------------------------------------------------------------
  # 📂 宣告式 Thunar 右鍵自訂動作 (在此開啟 Ghostty 終端機)
  xdg.configFile."Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
    <action>
    	<icon>utilities-terminal</icon>
    	<name>在此開啟 Ghostty 終端機</name>
    	<submenu></submenu>
    	<unique-id>1784342240697327-1</unique-id>
    	<command>thunar-open-terminal %f %d</command>
    	<description>在當前目錄開啟 Ghostty 終端機</description>
    	<range></range>
    	<patterns>*</patterns>
    	<startup-notify/>
    	<directories/>
    	<audio-files/>
    	<image-files/>
    	<other-files/>
    	<text-files/>
    	<video-files/>
    </action>
    </actions>
  '';

  # 🛠️ 宣告式 Thunar 設定 (視窗標題顯示完整路徑，供雙向跳轉精確讀取)
  xfconf.settings = {
    thunar = {
      "misc-window-title-style" = "THUNAR_WINDOW_TITLE_STYLE_FULL_PATH_WITHOUT_THUNAR_SUFFIX";
      "misc-full-path-in-tab-titles" = true;
    };
  };

  # 🚀 註冊跳轉捷徑至應用程式選單 (支援 Walker 搜尋與啟動)
  xdg.desktopEntries.jump-folder = {
    name = "Jump Folder (Terminal ⇄ FM)";
    comment = "Toggle between Ghostty and Thunar in current directory";
    exec = "jump-folder";
    icon = "folder-open";
    categories = [ "Utility" ];
    terminal = false;
  };

  # ----------------------------------------------------------------------------
  # 🎧 藍牙耳機設定檔自動切換控制腳本 (放置於 ~/.local/bin)
  # ----------------------------------------------------------------------------
  home.file.".local/bin/bt-autoswitch-off" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -e
      # 關閉 WirePlumber 藍牙自動切換 (避免手動切至 CVSD/mSBC 時在幾秒內被自動彈回 AAC)
      ${pkgs.wireplumber}/bin/wpctl settings --save bluetooth.autoswitch-to-headset-profile false
      ${pkgs.systemd}/bin/systemctl --user restart wireplumber
      if command -v notify-send >/dev/null 2>&1; then
        notify-send "WirePlumber" "藍牙自動切換已【關閉】\n(已固定當前設定檔，不會自動切回 AAC)" -i audio-headphones 2>/dev/null || true
      fi
      echo "WirePlumber: bluetooth.autoswitch-to-headset-profile = false (WirePlumber restarted)"
    '';
  };

  home.file.".local/bin/bt-autoswitch-on" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -e
      # 開啟 WirePlumber 藍牙自動切換 (錄音通話時自動切為耳麥模式)
      ${pkgs.wireplumber}/bin/wpctl settings --save bluetooth.autoswitch-to-headset-profile true
      ${pkgs.systemd}/bin/systemctl --user restart wireplumber
      if command -v notify-send >/dev/null 2>&1; then
        notify-send "WirePlumber" "藍牙自動切換已【開啟】\n(錄音通話時自動切換至耳麥模式)" -i audio-headset 2>/dev/null || true
      fi
      echo "WirePlumber: bluetooth.autoswitch-to-headset-profile = true (WirePlumber restarted)"
    '';
  };

  xdg.desktopEntries.bt-autoswitch-off = {
    name = "Disable BT Headset Autoswitch";
    comment = "Disable WirePlumber Bluetooth autoswitch to prevent reverting to AAC";
    exec = "bt-autoswitch-off";
    icon = "audio-headphones";
    categories = [
      "Settings"
      "Audio"
    ];
    terminal = false;
  };

  xdg.desktopEntries.bt-autoswitch-on = {
    name = "Enable BT Headset Autoswitch";
    comment = "Enable WirePlumber Bluetooth autoswitch on record/call";
    exec = "bt-autoswitch-on";
    icon = "audio-headset";
    categories = [
      "Settings"
      "Audio"
    ];
    terminal = false;
  };

  # ----------------------------------------------------------------------------
  # 👑 SECTION 11: Home Manager 核心維護宣告
  # ----------------------------------------------------------------------------
  programs.home-manager.enable = true;
}
