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
  # ⌨️ SECTION 2: 全域輸入法與環境變數對齊 (Wayland Input Method)
  # ----------------------------------------------------------------------------
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx5";
    QT_IM_MODULE = "fcitx5";
    XMODIFIERS = "@im=fcitx5";
    IMSETTINGS_MODULE = "fcitx5";
  };

  # ----------------------------------------------------------------------------
  # 📦 SECTION 3: 個人軟體包依賴代管 (User-level Packages)
  # ----------------------------------------------------------------------------
  home.packages = with pkgs; [
    # 🦀 Rust 現代化 CLI 刀組 (Rewrite It In Rust)
    ripgrep             # 宇宙最快純文字搜尋引擎
    fd                  # 簡單、快速的尋找工具
    dust                # 樹狀圖顯示硬碟佔用
    procs               # 現代化進程檢視器
    tokei               # 程式碼行數與語言佔比統計
    hyperfine           # 命令行基準測試神器
    delta               # 帶有語法高亮與行號的極美 Git Diff 工具

    # 📝 學術論文與開發必備
    tectonic            # 基於 Rust 的自給自足式 LaTeX 引擎
    lazygit             # 終端機裡的 Git 圖形化整合介面
    # ghostty 已經物理移交至 programs.ghostty 模組託管，此處安全隱藏
    gnumake             # 傳統 GNU Make 編譯工具
    gcc                 # GNU 語言編譯器套件 (C/C++)

    # 🚀 程式語言與開發環境 (LSP 依賴)
    go                  # Go 程式語言編譯器與工具鏈
    rustc               # Rust 核心編譯器
    cargo               # Rust 套件管理器
    rustfmt             # Rust 程式碼格式化工具
    clippy              # Rust 靜態代碼分析工具
    temurin-bin-21      # Java 21 執行期環境 (JDK)
    python3             # Python 3 執行期環境
    pnpm                # 現代化、極速且節省空間的 Node.js 包管理器

    # 🗃️ 終端工作流與 Yazi 預覽增強
    tmux                # 終端機複用器
    ffmpegthumbnailer   # 影片縮圖生成器
    poppler-utils       # PDF 渲染工具套件

    # 📡 網路傳傳輸與遠端掛載
    aria2               # 多協定下載工具
    rsync               # 本地檔案快速同步工具
    sshfs               # 透過 SSH 掛載遠端目錄

    # 🖥️ 視窗管理與螢幕擷取 (Sway / Wayland 生態)
    grim                # Wayland 截圖工具
    slurp               # Wayland 區域選取工具
    brightnessctl       # 筆電螢幕亮度物理調度工具
    networkmanagerapplet
    hicolor-icon-theme
    wlogout             # 高雅 Wayland 電源選單
    swaylock            # Lock 按鈕實體依賴
    nwg-drawer          # 全螢幕圖形化 App 啟動抽屜

    # 🎯 藍牙管理 GUI 核心組件
    blueman             # 藍牙管理面板與常駐系統托盤

    # 🎯 裝置管理員 GUI 雙子星
    hardinfo2           # 經典樹狀裝置管理員
    cpu-x               # 現代化 CPU-Z 複刻版

    # 🎯 現代化 CLI 硬體檢視器
    fastfetch           # 極速系統總覽
    pciutils            # 提供 lspci
    usbutils            # 提供 lsusb

    # 🎯 極輕量 GUI 檔案管理
    thunar
    tumbler             # Thunar 的圖片縮圖生成引擎

    # 🎯 現代化音效調度刀組 (PipeWire 體系)
    pavucontrol         # GUI 音效主控台
    pulsemixer          # TUI 終端機音量調節器
    pasystray           # 系統托盤音效管理員

    # 🎯 檔案與剪貼簿臨時置物架防線
    copyq
    wl-clipboard        # Wayland 底層剪貼簿後端

    # 🎯 即時通訊軟體區
    telegram-desktop
    karere

    # 🖨️ 印表機和掃描器
    simple-scan           # GNOME 家族的極簡掃描器
    system-config-printer # 傳統的 GTK3 印表機管理面板

    # 螢幕管理
    wlr-randr            # CLI 螢幕管理
    wdisplays            # Sway/Wayland 專用圖形化螢幕管理面板

    # 🎯 Wayland 專屬輕量通知守護進程
    mako

    # 📦 個人專屬解壓縮兵器庫
    p7zip               # 萬能的 7z 核心
    zip                 # 標準 zip 壓縮工具
    unzip               # 解 zip 專用老將
    unrar               # 物理超渡 rar 檔案
    zstd                # 現代最速壓縮協議
    file-roller         # 極輕量 GTK 解壓縮總管

    # 🎨 Wayland 頂級動態桌布後台與滑鼠點選 GUI 前端
    awww
    waypaper

    # PDF 軟體
    kdePackages.okular
    zathura
    xdotool             # 焦點彈回實體依賴

    # 📦 隔離污染源專用沙盒
    distrobox

    # 📄️ 文書處理
    onlyoffice-desktopeditors
  ];

  # ----------------------------------------------------------------------------
  # 🐚 SECTION 4: Zsh 終端 Shell 與 Antidote 外掛管理機制
  # ----------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll   = "ls -l";
      g    = "git";
      nr   = "git add -A && sudo nixos-rebuild switch --flake ~/.config/nixos/#\${NIX_PROFILE:-pve-profile} && exec zsh";
      nxc  = "sudo nix-collect-garbage --delete-old";
      nxcg = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      nxl  = "sudo nixos-rebuild list-generations";
      cat  = "bat";
      top  = "btm";
      aria = "aria2c";
      y    = "yazi";
      mn   = "udisksctl mount -b";
      umn  = "udisksctl unmount -b";
      poff = "udisksctl power-off -b";
      dls  = "head -n 1 ~/.local/share/direnv/allow/* 2>/dev/null";
    };

    antidote = {
      enable = true;
      plugins = [
        "zsh-users/zsh-completions"
        "ohmyzsh/ohmyzsh path:plugins/git"
        "ohmyzsh/ohmyzsh path:plugins/sudo"
      ];
    };
  };

  # ----------------------------------------------------------------------------
  # 💻 Ghostty 終端機專屬字型防線
  # ----------------------------------------------------------------------------
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;

      # 🎯 修正主題名稱字串：改為官方指定的大寫空格 Title Case
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

  # ----------------------------------------------------------------------------
  # 🎨 SECTION 5: Starship 現代化跨 Shell 提示字元設定
  # ----------------------------------------------------------------------------
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
  # 📝 SECTION 6: Neovim 編輯器與配置管理
  # ----------------------------------------------------------------------------
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      git gcc gnumake ripgrep fd gopls rust-analyzer lua-language-server stylua
      google-java-format prettier eslint_d black isort clang-tools tex-fmt
    ];
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (p: with p; [
        html css vim lua javascript typescript latex go java r c cpp pug vue markdown markdown_inline json yaml bash python csv
      ]))
    ];
  };

  xdg.configFile."nvim".source = ./dotfiles/nvim;

  # ----------------------------------------------------------------------------
  # 🛠️ SECTION 7: 現代化系統服務與 CLI 工具鏈
  # ----------------------------------------------------------------------------
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

  # ----------------------------------------------------------------------------
  # 🖥️ SECTION 8: Wayland 視窗管理 (Sway, Waybar & GTK)
  # ----------------------------------------------------------------------------
  services.network-manager-applet.enable = true;

  gtk = {
    enable = true;
    iconTheme = { name = "Adwaita"; package = pkgs.adwaita-icon-theme; };
    theme = { name = "Adwaita-dark"; package = pkgs.gnome-themes-extra; };
  };

  # 📊 Waybar 頂部狀態列設定
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

      window#waybar { background-color: transparent; }

      #workspaces button {
        padding: 0 10px; margin: 4px 2px;
        background-color: rgba(30, 30, 46, 0.7); color: #cdd6f4;
        border-radius: 6px;
      }

      #workspaces button.focused { background-color: #ca9ee6; color: #1e1e2e; }

      #clock {
        /* 🎯 修正：同步修正 Clock 的第一順位字型 */
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
        font-weight: 500; /* 可以微調字重，讓它在工作列看起來更俐落 */
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
      menu = "wofi --show drun";

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
        "${mod}+c" = "exec copyq toggle";

        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute"        = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessUp"   = "exec brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
      };

      input = {
        "type:pointer" = { natural_scroll = "enabled"; accel_profile = "flat"; pointer_accel = "0.6"; };
        "type:touchpad" = { natural_scroll = "enabled"; tap = "enabled"; middle_emulation = "enabled"; };
      };

      startup = [
        { command = "fcitx5 -d --replace"; always = true; }
        { command = "awww-daemon & sleep 0.5 && waypaper --restore"; always = true; }
        { command = "blueman-applet"; always = true; }
        { command = "pasystray"; always = true; }
        { command = "copyq"; always = true; }
        { command = "mako"; always = true; }
      ];

      bars = [ ];

      assigns = {
        "2" = [ { app_id = "^org\\.telegram\\.desktop$"; } { app_id = "^io\\.github\\.tobagin\\.karere$"; } ];
      };

      window.commands = [
        { command = "floating enable"; criteria = { title = "^LINE$"; }; }
        { command = "floating enable, border none, move position 85 ppt 3 ppt"; criteria = { app_id = "^$"; title = "^$"; }; }
        { command = "floating enable, resize set 400 px 900 px, move position 75 ppt 5 ppt"; criteria = { app_id = "^com\\.github\\.hluk\\.copyq$"; }; }
        { command = "floating enable"; criteria = { app_id = "^(org\\.telegram\\.desktop|io\\.github\\.tobagin\\.karere)$"; }; }
        { command = "floating enable"; criteria = { app_id = "^org\\.gnome\\.FileRoller$"; }; }
        { command = "floating enable, resize set 1000 700, move position center"; criteria = { app_id = "wdisplays"; }; }
        { command = "floating enable, resize set 1100 750, move position center"; criteria = { app_id = "waypaper"; }; }
      ];
    };
    extraConfig = ''
      no_focus [app_id="^$" title="^$"]
    '';
  };

  # 🌐 XDG Desktop Portal 總線防線
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config = { sway = { default = [ "wlr" ]; }; };
  };

  # 🎯 Mako 通知美學宣告防線：Catppuccin Macchiato 風格
  services.mako = {
    enable = true;

    # 💡 順應 26.05 新模組規範，並精準修正為 LINE Seed TW_TTF 字型真名
    settings = {
      font = "LINE Seed TW_TTF,JetBrainsMono Nerd Font Regular 10";
      background-color = "#24273add";  # 內斂的摩卡深藍
      text-color = "#cad3f5";          # 粉白文字
      border-color = "#8aadf4";        # 科技感淡藍邊框
      border-size = 2;
      border-radius = 6;
      margin = "15,15";
      padding = "12,18";
      default-timeout = 6000;          # 6秒後自動隱形
    };
  };

  # 🎨 nwg-drawer 全螢幕抽屜視覺定製 (Catppuccin Macchiato 風格)
  xdg.configFile."nwg-drawer/drawer.css".text = ''
    window {
      background-color: rgba(36, 39, 58, 0.88); /* 摩卡深藍 + 優雅毛玻璃半透明 */
      color: #cad3f5;
      font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font", sans-serif;
    }

    /* 頂部搜尋欄 */
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

    /* 頂部應用程式分類標籤（All, Internet, Programming...） */
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

    /* 應用程式圖示按鈕 */
    #app-button {
      color: #cdd6f4;
      padding: 12px;
      border-radius: 8px;
    }
    #app-button:hover {
      background-color: rgba(255, 255, 255, 0.08);
    }
  '';

  # ----------------------------------------------------------------------------
  # 🎨 SECTION 9: 應用程式啟動與關機選單自訂 (Wofi & Wlogout)
  # ----------------------------------------------------------------------------
  # 🎩 Wofi 啟動器設定
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun"; width = 600; height = 400; always_parse_args = true;
      show_indicators = true; insensitive = true; allow_images = true; image_size = 28;
      prompt = "搜尋應用程式...";
    };
    style = ''
      window {
        /* 🎯 修正：將 CSS 內字型更正為 LINE Seed TW_TTF */
        font-family: "LINE Seed TW_TTF", "JetBrainsMono Nerd Font", sans-serif;
        font-size: 14px;
        background-color: rgba(30, 30, 46, 0.85); color: #cdd6f4;
        border: 2px solid rgba(202, 158, 230, 0.3); border-radius: 12px;
      }

      #outer-box { padding: 15px; }
      #input {
        background-color: rgba(49, 50, 68, 0.5); color: #cdd6f4;
        border: 1px solid rgba(202, 158, 230, 0.2); border-radius: 8px;
        padding: 8px 12px; margin-bottom: 10px;
      }
      #input:focus { border-color: #ca9ee6; box-shadow: 0 0 4px rgba(202, 158, 230, 0.5); }
      #scroll { margin-top: 5px; }
      #text { color: #cdd6f4; margin-left: 10px; }
      #entry { padding: 8px; border-radius: 8px; transition: all 0.1s ease-in-out; }
      #entry:selected { background-color: rgba(202, 158, 230, 0.3); outline: none; }
      #entry:selected #text { color: #ca9ee6; font-weight: bold; }
    '';
  };

  # ⏻ Wlogout 六宮格
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
      /* 🎯 修正：更正 wlogout 內部渲染字型為 LINE Seed TW_TTF */
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
  # 📝 SECTION 10: 全域代碼與協定規範 (EditorConfig & SSH Config)
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
    };
  };

  # ----------------------------------------------------------------------------
  # 👑 SECTION 11: Home Manager 核心維護宣告
  # ----------------------------------------------------------------------------
  programs.home-manager.enable = true;
}
