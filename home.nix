# ==============================================================================
# ❄️ National Kaohsiung University of Science and Technology - Workstation Config
# 🛠️ Home Manager Configuration (home.nix)
# ==============================================================================

{ config, pkgs, lib, ... }:

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
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    IMSETTINGS_MODULE = "fcitx";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # ----------------------------------------------------------------------------
  # 📦 SECTION 3: 個人軟體包依賴代管 (User-level Packages)
  # ----------------------------------------------------------------------------
  home.packages = with pkgs;
    let
      # 1. 宣告包好套件的 R 核心
      myR = rWrapper.override {
        packages = with rPackages; [
          tidyverse      # 已包含 ggplot2, dplyr, readr, tidyr, purrr 等核心套件
          devtools       # 套件開發工具
          rmarkdown      # 動態報告輸出
          knitr          # 報告編織工具
          styler         # 提供 styler 以供 RFormat 呼叫
          languageserver # 給 Neovim (nvim-lspconfig) 使用的 LSP Server
        ];
      };
      # 2. 宣告使用此 R 核心的 RStudio
      myRStudio = rstudioWrapper.override {
        packages = [ myR ];
      };
  in
  [
    # 🦀 Rust 現代化 CLI 刀組 (Rewrite It In Rust)
    ripgrep             # 宇宙最快純文字搜尋引擎
    fd                  # 簡單、快速的尋找工具
    dust                # 樹狀圖顯示硬碟佔用
    procs               # 現代化進程檢視器
    tokei               # 程式碼行數與語言佔比統計
    hyperfine           # 命令行基準測試神器
    delta               # 帶有語法高亮與行號的極美 Git Diff 工具

    # 其他 CLI 工具
    sc-im
    (pkgs.visidata.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ (with pkgs.python3Packages; [
        pandas       # 數據分析與高級計算
        openpyxl     # Excel 讀寫支援
        zstandard    # zstd 壓縮格式
      ]);
    }))

    # 📝 學術論文與開發必備
    tectonic            # 基於 Rust 的自給自足式 LaTeX 引擎
    lazygit             # 終端機裡的 Git 圖形化整合介面
    gnumake             # 傳統 GNU Make 編譯工具
    gcc                 # GNU 語言編譯器套件 (C/C++)
    neovide             # nvim 的 GUI

    # 🚀 程式語言與開發環境 (LSP 依賴)
    go                  # Go 程式語言編譯器與工具鏈
    rustc               # Rust 核心編譯器
    cargo               # Rust 套件管理器
    rustfmt             # Rust 程式碼格式化工具
    clippy              # Rust 靜態代碼分析工具
    temurin-bin-21      # Java 21 執行期環境 (JDK)
    gradle
    python3             # Python 3 執行期環境
    uv                  # 🦀 極速 Rust 打造的 Python 套件與環境管理器
    nodejs
    pnpm                # 現代化、極速且節省空間的 Node.js 包管理器
    lua5_4
    myR        # 👈 提供 Terminal 裡的 `R` 與 `Rscript` 指令
    myRStudio  # 👈 提供 RStudio 圖形介面

    # 🗃️ 終端工作流與 Yazi 預覽增強
    tmux                # 終端機複用器
    ffmpegthumbnailer   # 影片縮圖生成器
    poppler-utils       # PDF 渲染工具套件

    # 📡 網路傳輸與遠端掛載
    aria2               # 多協定下載工具
    rsync               # 本地檔案快速同步工具
    sshfs               # 透過 SSH 掛載遠端目錄

    # 🖥️ 視窗管理與螢幕擷取 (Sway / Wayland 生態)
    cliphist            # 專為 Wayland 打造的極輕量 SQLite 剪貼簿後端
    wl-clipboard        # Wayland 底層剪貼簿後端
    dragon-drop         # 🐉 Linux 界神級暫存拖曳工具 (Yoink 核心)
    grim                # Wayland 截圖工具
    slurp               # Wayland 區域選取工具
    brightnessctl       # 筆電螢幕亮度物理調度工具
    networkmanagerapplet
    hicolor-icon-theme
    wlogout             # 高雅 Wayland 電源選單
    swaylock            # Lock 按鈕實體依賴
    swayidle            # Idle 按鈕實體依賴
    nwg-drawer          # 全螢幕圖形化 App 啟動抽屜
    polkit_gnome        # GTK 提權彈窗代理
    playerctl           # 多媒體按鍵控制 CLI
    hyprpicker          # Wayland 螢幕吸管/取色器
    trash-cli           # CLI 安全回收桶工具
    appimage-run        # AppImage 程式執行

    # 📸 1. 自訂一鍵區域截圖指令
    (writeShellScriptBin "shot-area" ''
      FILE="$HOME/Pictures/Screenshot_$(date +%Y%m%d_%H%M%S).png"
      REGION=$(${pkgs.slurp}/bin/slurp)

      [ -z "$REGION" ] && exit 0

      ${pkgs.grim}/bin/grim -g "$REGION" "$FILE"
      ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
      ${pkgs.libnotify}/bin/notify-send -a "Screenshot" "📸 區域截圖完成" "已複製並存檔至 ~/Pictures"
    '')

    # 📸 2. 自訂全螢幕截圖指令
    (writeShellScriptBin "shot-full" ''
      FILE="$HOME/Pictures/Screenshot_$(date +%Y%m%d_%H%M%S)_full.png"
      ${pkgs.grim}/bin/grim "$FILE"
      ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
      ${pkgs.libnotify}/bin/notify-send -a "Screenshot" "📸 全螢幕截圖完成" "已複製並存檔至 ~/Pictures"
    '')

    # 3. 建立 zathura 反向搜尋設定
    (pkgs.writeShellScriptBin "zathura-remote-nvim" ''
      SERVER=$(cat /tmp/curserver 2>/dev/null)
      if [ -n "$SERVER" ]; then
        nvim --server "$SERVER" --remote-send "<C-\><C-N>:e $1<CR>:$2<CR>"
      fi
    '')

    # 🎯 藍牙與硬體檢視 GUI
    blueman             # 藍牙管理面板與常駐系統托盤
    hardinfo2           # 經典樹狀裝置管理員
    cpu-x               # 現代化 CPU-Z 複刻版
    fastfetch           # 極速系統總覽
    pciutils            # 提供 lspci
    usbutils            # 提供 lsusb

    # 🎯 極輕量 GUI 檔案管理
    (thunar.override {
      thunarPlugins = [
        thunar-archive-plugin
        thunar-volman
      ];
    })
    tumbler             # Thunar 的圖片縮圖生成引擎

    # 🎯 現代化音效調度刀組 (PipeWire 體系)
    pavucontrol         # GUI 音效主控台
    pulsemixer          # TUI 終端機音量調節器
    pasystray           # 系統托盤音效管理員

    # 🎯 即時通訊軟體區
    telegram-desktop
    karere
    wechat

    # 🖨️ 印表機和掃描器
    simple-scan         # GNOME 家族的極簡掃描器
    system-config-printer # 傳統的 GTK3 印表機管理面板

    # 螢幕管理
    wlr-randr           # CLI 螢幕管理
    wdisplays           # Sway/Wayland 專用圖形化螢幕管理面板

    # 🎯 Wayland 專屬輕量通知守護進程
    mako

    # 📦 個人專屬解壓縮兵器庫
    p7zip               # 萬能的 7z 核心
    zip                 # 標準 zip 壓縮工具
    unzip               # 解 zip 專用老將
    unrar               # 物理超渡 rar 檔案
    zstd                # 現代最速壓縮協議
    file-roller         # 極輕量 GTK 解壓縮總管

    # 🎨 Wayland 頂級動態桌布後台與 GUI 前端
    awww
    waypaper

    # PDF 軟體
    kdePackages.okular
    zathura
    xdotool             # 焦點彈回實體依賴

    # 📦 隔離污染源專用沙盒
    distrobox

    # 📄 文書處理與媒體工具
    onlyoffice-desktopeditors
    yt-dlp              # MPV 4K 網址串流擴充

    # 🖥️ 計算機引擎
    libqalculate
    qalculate-gtk

    # 圖片瀏覽
    geeqie              # 經典硬派極速 ACDSee
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
      "highlight-color" = "rgba(249, 226, 175, 0.35)";        # 一般高亮 (Catppuccin Yellow)
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
    '';

    shellAliases = {
      ll       = "ls -l";
      g        = "git";
      nr       = "git add -A && sudo nixos-rebuild switch --flake ~/.config/nixos/#\${NIX_PROFILE:-pve-profile} && exec zsh";
      nxc      = "sudo nix-collect-garbage --delete-old";
      nxcg     = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      nxl      = "sudo nixos-rebuild list-generations";
      cat      = "bat";
      top      = "btm";
      aria     = "aria2c";
      y        = "yazi";
      mn       = "udisksctl mount -b";
      umn      = "udisksctl unmount -b";
      poff     = "udisksctl power-off -b";
      ch-clear = "cliphist wipe";
      cb2file  = "wl-paste > ~/Pictures/Clip_\$(date +%Y%m%d_%H%M%S).png && echo '📸 剪貼簿圖片已存至 ~/Pictures'";
      tp       = "trash-put";
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
        conflicted = "💥 "; ahead = "⇡×$count"; behind = "⇣×$count";
        untracked = "➕ "; staged = "📦 "; modified = "📝 "; deleted = "🗑️ ";
      };
      character = {
        success_symbol = "[](cyan bold green) ";
        error_symbol   = "[](cyan bold red) ";
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
      git gcc gnumake ripgrep fd gopls rust-analyzer lua-language-server stylua
      google-java-format prettier eslint_d black isort clang-tools lldb tex-fmt
      vscode-extensions.vadimcn.vscode-lldb.adapter delve texlab harper
      jdt-language-server ltex-ls-plus marksman pyright ruff python3Packages.debugpy
      vscode-extensions.vscjava.vscode-java-debug tree-sitter
      vscode-extensions.vscjava.vscode-java-test
      vscode-langservers-extracted
      typescript-language-server
      vue-language-server
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
      "--height 40%" "--layout=reverse" "--border" "--inline-info"
      "--preview 'if [ -d {} ]; then fd --max-depth 1 . {}; else bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || head -100 {}; fi'"
    ];
  };

  programs.bat = {
    enable = true;
    config = { theme = "Nord"; style = "numbers,changes,header"; };
  };

  programs.bottom = {
    enable = true;
    settings.flags = {
      celsius = true; rate = 1000; remember_sort = true;
      avg_cpu = false; battery = false;
    };
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" "--header" "--octal-permissions" ];
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
        l = ["log" "-r" "all()"];
        s = ["status"];
        d = ["diff"];
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
    iconTheme = { name = "Adwaita"; package = pkgs.adwaita-icon-theme; };
    theme = { name = "Adwaita-dark"; package = pkgs.gnome-themes-extra; };
    cursorTheme = { name = "Adwaita"; package = pkgs.adwaita-icon-theme; size = 24; };
    font = { name = "LINE Seed TW_TTF"; size = 10; };
  };

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "sway-session.target" ];
    };
    settings = [{
      layer = "top"; position = "top"; height = 34; spacing = 8;
      modules-left = [ "sway/workspaces" "wlr/taskbar" ];
      modules-right = [ "cpu" "memory" "temperature" "tray" "clock" "custom/power" ];

      "sway/workspaces" = { disable-scroll = true; all-outputs = true; format = "{name}"; };
      "wlr/taskbar" = {
        format = "{icon} {title}";
        icon-size = 16;
        icon-theme = "Adwaita";
        tooltip-format = "{title}";
        on-click = "activate";
        on-click-middle = "close";
      };
      clock = { format = "{:%H:%M  |  %m/%d}"; tooltip-format = "<tt><small>{calendar}</small></tt>"; };
      cpu = { format = "CPU: {usage}%"; };
      memory = { format = "RAM: {used:0.1f}G"; };
      temperature = { critical-threshold = 75; format = "{temperatureC}°C"; };
      "custom/power" = { format = "⏻"; tooltip = false; on-click = "wlogout"; };
    }];
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
      #tray { font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font"; margin-right: 12px; padding: 0 6px; }

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
      menu = "fuzzel";

      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        style = "Regular";
        size = 11.0;
      };

      keybindings = let mod = modifier; in pkgs.lib.mkOptionDefault {
        "${mod}+Return" = "exec ${terminal}";
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
        "${mod}+h" = "focus left"; "${mod}+j" = "focus down"; "${mod}+k" = "focus up"; "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left"; "${mod}+Shift+j" = "move down"; "${mod}+Shift+k" = "move up"; "${mod}+Shift+l" = "move right";

        "${mod}+equal" = "exec ghostty --class=calc-pop -e qalc";
        "${mod}+c" = "exec cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";

        "${mod}+Ctrl+Shift+4" = "exec shot-area";
        "${mod}+Ctrl+Shift+3" = "exec shot-full";
        "${mod}+Ctrl+s" = "exec shot-area";

        "XF86AudioRaiseVolume"  = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume"  = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute"         = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessUp"   = "exec brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86AudioPlay"          = "exec playerctl play-pause";
        "XF86AudioNext"          = "exec playerctl next";
        "XF86AudioPrev"          = "exec playerctl previous";

        "${mod}+Shift+p" = "exec hyprpicker -a";
      };

      input = {
        "type:pointer" = { natural_scroll = "enabled"; accel_profile = "flat"; pointer_accel = "0.6"; };
        "type:touchpad" = { natural_scroll = "enabled"; tap = "enabled"; middle_emulation = "enabled"; };
      };

      startup = [
        { command = "awww-daemon & sleep 0.5 && waypaper --restore"; always = true; }
        { command = "blueman-applet"; always = true; }
        { command = "pasystray"; always = true; }
        { command = "nm-applet --indicator"; always = true; }
        { command = "wl-paste --type text --watch cliphist store"; always = true; }
        { command = "wl-paste --type image --watch cliphist store"; always = true; }
        { command = "mako"; always = true; }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; always = true; }
      ];

      bars = [ ];

      assigns = {
        "2" = [ { app_id = "^org\\.telegram\\.desktop$"; } { app_id = "^io\\.github\\.tobagin\\.karere$"; } ];
      };

      window.commands = [
        { command = "floating enable"; criteria = { title = "^LINE$"; }; }
        { command = "floating enable, border none, move position 85 ppt 3 ppt"; criteria = { app_id = "^$"; title = "^$"; }; }
        { command = "floating enable"; criteria = { app_id = "^(org\\.telegram\\.desktop|io\\.github\\.tobagin\\.karere)$"; }; }
        { command = "floating enable"; criteria = { app_id = "^org\\.gnome\\.FileRoller$"; }; }
        { command = "floating enable, resize set 1000 700, move position center"; criteria = { app_id = "wdisplays"; }; }
        { command = "floating enable, resize set 1100 750, move position center"; criteria = { app_id = "waypaper"; }; }
        { command = "floating enable"; criteria = { title = "音量控制"; }; }
        { command = "floating enable"; criteria = { title = "Qalculate!"; }; }
        { command = "floating enable, resize set 650 400, move position center"; criteria = { title = "^qalc$"; }; }
        { command = "floating enable, sticky enable, resize set 400 300"; criteria = { app_id = "dragon"; }; }
        { command = "floating enable, sticky enable, resize set 400 300"; criteria = { title = "dragon"; }; }
        { command = "floating enable, resize set 1200 800, move position center"; criteria = { app_id = "^org\\.geeqie\\.Geeqie$"; }; }
        { command = "floating enable, resize set 1200 800, move position center"; criteria = { class = "^Geeqie$"; }; }
        { command = "floating enable, resize set 1200 800, move position center"; criteria = { title = ".*Geeqie.*"; }; }
        { command = "floating enable, resize set 800 600, move position center"; criteria = { app_id = "system-config-printer"; }; }
        { command = "floating enable, resize set 900 650, move position center"; criteria = { app_id = "simple-scan"; }; }
        { command = "floating enable"; criteria = { title = "^R Graphics"; }; }
      ];
    };
    extraConfig = ''
      no_focus [app_id="^$" title="^$"]
    '';
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config = { sway = { default = [ "wlr" ]; }; };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "LINE Seed TW_TTF,JetBrainsMono Nerd Font Regular 10";
      background-color = "#24273add";
      text-color = "#cad3f5";
      border-color = "#8aadf4";
      border-size = 2;
      border-radius = 6;
      margin = "15,15";
      padding = "12,18";
      default-timeout = 6000;
    };
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

  services.wlsunset = {
    enable = true;
    sunrise = "06:30";
    sunset  = "18:30";
    temperature = {
      day = 6500;
      night = 4000;
    };
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = "swaylock -f -c 11111b"; }
      { timeout = 600; command = "swaymsg 'output * power off'"; resumeCommand = "swaymsg 'output * power on'"; }
    ];
    events = {
      before-sleep = "swaylock -f -c 11111b";
      lock = "swaylock -f -c 11111b";
    };
  };

  # ----------------------------------------------------------------------------
  # 🚀 SECTION 7: Launcher 與電源選單 (Fuzzel & Wlogout)
  # ----------------------------------------------------------------------------
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "LINE Seed TW_TTF:size=12, JetBrainsMono Nerd Font:size=12";
        prompt = "❯ ";
        terminal = "ghostty";
        layer = "overlay";
        width = 38;
        line-height = 28;
        fields = "filename,name,generic,exec,categories,keywords";
      };
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        match = "f5c2e7ff";
        selection = "cba6f7ff";
        selection-text = "11111bff";
        border = "cba6f7ff";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };

  programs.wlogout = {
    enable = true;
    layout = [
      { label = "lock"; action = "swaylock -f -c 11111b"; text = "Lock"; keybind = "l"; }
      { label = "logout"; action = "swaymsg exit"; text = "Logout"; keybind = "e"; }
      { label = "suspend"; action = "systemctl suspend"; text = "Suspend"; keybind = "u"; }
      { label = "hibernate"; action = "systemctl hibernate"; text = "Hibernate"; keybind = "h"; }
      { label = "shutdown"; action = "systemctl poweroff"; text = "Shutdown"; keybind = "p"; }
      { label = "reboot"; action = "systemctl reboot"; text = "Reboot"; keybind = "r"; }
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
    categories = [ "Network" "InstantMessaging" ];
  };

  # ----------------------------------------------------------------------------
  # 📝 SECTION 9: 全域代碼與協定規範 (EditorConfig, SSH, MIME & MPV)
  # ----------------------------------------------------------------------------
  editorconfig = {
    enable = true;
    settings = {
      "*" = { root = true; insert_final_newline = true; charset = "utf-8"; trim_trailing_whitespace = true; indent_style = "space"; indent_size = 2; };
      "{Makefile,go.mod,go.sum,*.go,.gitmodules,*.lua}" = { indent_style = "tab"; indent_size = 4; };
      "*.{py,js}" = { indent_size = 4; }; "*.swift" = { indent_size = 4; }; "*.rs" = { indent_size = 4; }; "*.java" = { indent_size = 2; };
      "*.md" = { indent_size = 4; trim_trailing_whitespace = false; eclint_indent_style = "unset"; };
      "*.{c++,cc,cpp,cxx,h,h++,hh,hpp,hxx,inl,ipp,tlh,tli}" = { cpp_indent_case_contents_when_block = true; cpp_new_line_before_open_brace_namespace = "same_line"; };
      "*.slint" = { indent_size = 4; }; "Dockerfile" = { indent_size = 4; };
    };
  };

  programs.ssh = {
    enableDefaultConfig = false;
    settings."*" = { Compression = "yes"; ServerAliveInterval = 60; };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.kde.okular.desktop" ];
      "inode/directory" = [ "thunar.desktop" ];

      # 🌐 預設網頁瀏覽器與 Protocol 處理器
      "text/html"               = [ "google-chrome.desktop" ];
      "x-scheme-handler/http"     = [ "google-chrome.desktop" ];
      "x-scheme-handler/https"    = [ "google-chrome.desktop" ];
      "x-scheme-handler/about"    = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown"  = [ "google-chrome.desktop" ];

      # 🖼️ 預設圖片瀏覽器：Geeqie
      "image/jpeg"                    = [ "org.geeqie.Geeqie.desktop" ];
      "image/png"                     = [ "org.geeqie.Geeqie.desktop" ];
      "image/gif"                     = [ "org.geeqie.Geeqie.desktop" ];
      "image/webp"                    = [ "org.geeqie.Geeqie.desktop" ];
      "image/tiff"                    = [ "org.geeqie.Geeqie.desktop" ];
      "image/bmp"                     = [ "org.geeqie.Geeqie.desktop" ];
      "image/svg+xml"                 = [ "org.geeqie.Geeqie.desktop" ];
      "image/vnd.microsoft.icon"      = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-icon"                  = [ "org.geeqie.Geeqie.desktop" ];

      "image/avif"                    = [ "org.geeqie.Geeqie.desktop" ];
      "image/heif"                    = [ "org.geeqie.Geeqie.desktop" ];
      "image/heic"                    = [ "org.geeqie.Geeqie.desktop" ];
      "image/jxl"                     = [ "org.geeqie.Geeqie.desktop" ];

      "image/x-tga"                   = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-pcx"                   = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-portable-anymap"       = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-portable-bitmap"       = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-portable-pixmap"       = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-xbitmap"               = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-xpixmap"               = [ "org.geeqie.Geeqie.desktop" ];

      "image/x-canon-cr2"             = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-canon-crw"             = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-nikon-nef"             = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-sony-arw"              = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-adobe-dng"             = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-olympus-orf"           = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-fuji-raf"              = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-panasonic-raw"         = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-pentax-pef"            = [ "org.geeqie.Geeqie.desktop" ];
      "image/x-dcraw"                 = [ "org.geeqie.Geeqie.desktop" ];
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
      uosc      # 👑 現代化動態 UI / 雙語字幕選單 / 控制面板
      thumbfast # 📸 懸停時間軸時顯示影片實體縮圖
      mpris     # 🎵 打通 D-Bus 供 Waybar 媒體控制
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
  # 👑 SECTION 10: Home Manager 核心維護宣告
  # ----------------------------------------------------------------------------
  programs.home-manager.enable = true;
}
