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
  # 🎯 注入 Wayland 環境變數，確保 Sway 底下所有軟體（GTK/Qt/Ghostty）能順暢呼叫 Fcitx5
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
    ripgrep             # 宇宙最快純文字搜尋引擎，Neovim/Telescope 核心
    fd                  # 簡單、快速且預設忽略 gitignore 的尋找工具
    dust                # 用直觀樹狀圖與百分比顯示硬碟佔用的工具
    procs               # 支援彩色輸出與 Port 查詢的現代化進程檢視器
    tokei               # 毫秒級程式碼行數與語言佔比統計工具
    hyperfine           # 命令行基準測試 (Benchmark) 神器，資工效能調校必備
    delta               # 帶有語法高亮與行號的極美 Git Diff 工具

    # 📝 學術論文與開發必備
    tectonic            # 基於 Rust 的自給自足式 LaTeX 引擎
    lazygit             # 終端機裡的 Git 圖形化整合介面
    ghostty             # 現代化、支援 GPU 加速的頂級終端機
    gnumake             # 傳統 GNU Make 編譯工具
    gcc                 # GNU 語言編譯器套件 (C/C++)

    # 🚀 程式語言與開發環境 (LSP 依賴)
    go                  # Go 程式語言編譯器與工具鏈
    rustc               # Rust 核心編譯器
    cargo               # Rust 套件管理器
    rustfmt             # Rust 程式碼格式化工具
    clippy              # Rust 靜態代碼分析 (Linter) 工具
    temurin-bin-21      # Java 21 執行期環境 (JDK)
    python3             # Python 3 執行期環境
    pnpm                # 現代化、極速且節省空間 of Node.js 包管理器

    # 🗃️ 終端工作流與 Yazi 預覽增強
    tmux                # 終端機複用器 (Terminal Multiplexer)
    ffmpegthumbnailer   # 影片縮圖生成器 (供 yazi 預覽影片使用)
    poppler-utils       # PDF 渲染工具套件 (提供 pdftoppm 供 yazi 預覽 PDF)

    # 📡 網路傳輸與遠端掛載
    aria2               # 極速、輕量化的多協定下載工具 (支援 BT/HTTP)
    rsync               # 經典的遠端與本地檔案快速同步工具
    sshfs               # 透過 SSH 將遠端目錄掛載至地端的檔案系統

    # 🖥️ 視窗管理與螢幕擷取 (Sway / Wayland 生態)
    grim                # Wayland 截圖工具 (抓取畫面)
    slurp               # Wayland 區域選取工具 (配合 grim 擷取特定區域)
    swaybg              # Wayland 桌布設定工具
    networkmanagerapplet
    hicolor-icon-theme
    wlogout             # 🎯 物理替代 swaynag 的高雅 Wayland 電源選單
    swaylock            # 🎯 補上這個，Lock 按鈕才動得起來
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
      # 🎯 終極防線：讀取本地環境變數 $NIX_PROFILE，若無設定則預設以 pve-profile 安全配置
      nr   = "git add -A && sudo nixos-rebuild switch --flake ~/.config/nixos/#\${NIX_PROFILE:-pve-profile} && exec zsh";
      nxc  = "sudo nix-collect-garbage --delete-old";
      nxcg = "nix-env --delete-generations old && nix-store --gc";
      nxl  = "sudo nixos-rebuild list-generations";
      cat  = "bat";
      top  = "btm";
      aria = "aria2c";
      y    = "yazi";
      # 🔌 隨身碟 CLI 極速掛載武器庫
      mn   = "udisksctl mount -b";
      umn  = "udisksctl unmount -b";
      poff = "udisksctl power-off -b";
      # 🛰️ 一槍清點全系統被 direnv 列管的黃金地段
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true; # 🎯 自動幫您在 Zsh 注入 hook
    options = [
      "--cmd cd"                 # 🎯 物理劫持傳統的 cd 命令
    ];
  };

  # ----------------------------------------------------------------------------
  # 🎨 SECTION 5: Starship 現代化跨 Shell 提示字元（Prompt）設定
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
      # 🎯 告訴 Git 引擎：我們不要用 GPG，改用 SSH 格式簽署
      gpg.format = "ssh";
    };

    # 🔐 現代化 SSH 簽署防線
    signing = {
      key = "~/.ssh/id_ed25519.pub"; # 🎯 指向您本機的 SSH 公鑰路徑
      signByDefault = true;
    };
  };

  # ----------------------------------------------------------------------------
  # 🖥️ SECTION 8: Wayland 視窗管理 (Sway, Waybar & GTK)
  # ----------------------------------------------------------------------------
  services.network-manager-applet.enable = true; # Sway 網路狀態欄位

  # 🎨 完美的 GTK 視覺防線（解決 nm-applet 圖示遺失問題）
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
  };

  # 📊 Waybar 頂部狀態列
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "sway-session.target" ];
    };
    settings = [{
      layer = "top"; position = "top"; height = 34; spacing = 8;
      modules-left = [ "sway/workspaces" ];
      modules-right = [ "cpu" "memory" "temperature" "tray" "clock" "custom/power" ];

      "sway/workspaces" = { disable-scroll = true; all-outputs = true; format = "{name}"; };
      clock = { format = "{:%H:%M  |  %m/%d}"; tooltip-format = "<tt><small>{calendar}</small></tt>"; };
      cpu = { format = "CPU: {usage}%"; };
      memory = { format = "RAM: {used:0.1f}G"; };
      temperature = { critical-threshold = 75; format = "{temperatureC}°C"; };

      "custom/power" = {
        format = "⏻";
        tooltip = false;
        on-click = "wlogout";
      };
    }];
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK TC", sans-serif;
        font-size: 13px;
        font-weight: 600;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: transparent;
      }

      #workspaces button {
        padding: 0 10px;
        margin: 4px 2px;
        background-color: rgba(30, 30, 46, 0.7);
        color: #cdd6f4;
        border-radius: 6px;
      }

      #workspaces button.focused {
        background-color: #ca9ee6;
        color: #1e1e2e;
      }

      #clock {
        font-family: "JetBrainsMono Nerd Font";
        padding: 0 16px;
        margin: 4px 0;
        background-color: rgba(30, 30, 46, 0.85);
        color: #f2cdcd;
        border-radius: 8px;
        border: 1px solid rgba(255, 255, 255, 0.1);
      }

      #cpu { color: #89b4fa; }
      #memory { color: #a6e3a1; }
      #temperature { color: #eba0ac; }

      #tray {
        margin-right: 12px;
        padding: 0 6px;
      }

      #tray > * {
        padding: 0 8px;
        margin: 0 4px;
      }

      #custom-power {
        color: #f38ba8;
        font-size: 14px;
        padding: 0 12px;
        margin: 4px 4px;
        background-color: rgba(243, 139, 168, 0.15);
        border-radius: 6px;
      }

      #custom-power:hover {
        background-color: rgba(243, 139, 168, 0.3);
      }
    '';
  };

  # 🌀 Sway 視窗管理器配置
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "wofi --show drun";
      keybindings = let mod = modifier; in pkgs.lib.mkOptionDefault {
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+d" = "exec ${menu}";
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
      };

      # 滑鼠與觸控板硬體配置
      input = {
        "type:pointer" = {
          natural_scroll = "enabled"; # 修正拼字：確保自然捲動正常
          accel_profile = "flat";     # 關閉滑鼠加速，確保一對一線性手感
          pointer_accel = "0.6";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
          middle_emulation = "enabled";
        };
      };

      startup = [
        # 啟動 Fcitx5，使用 --replace 確保能無縫劫持輸入法焦點
        { command = "fcitx5 -d --replace"; always = true; }
        { command = "swaybg -i ${pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath} -m fill"; always = true; }
      ];

      bars = [ ]; # 物理遮蔽 Sway 內建狀態列
    };
  };

  # ----------------------------------------------------------------------------
  # 🎨 SECTION 9: 應用程式啟動與關機選單自訂 (Wofi & Wlogout)
  # ----------------------------------------------------------------------------
  # 🎩 Wofi 啟動器
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 600;
      height = 400;
      always_parse_args = true;
      show_indicators = true;
      insensitive = true;
      allow_images = true;
      image_size = 28;
      prompt = "搜尋應用程式...";
    };
    style = ''
      window {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK TC", sans-serif;
        font-size: 14px;
        background-color: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
        border: 2px solid rgba(202, 158, 230, 0.3);
        border-radius: 12px;
      }

      #outer-box { padding: 15px; }

      #input {
        background-color: rgba(49, 50, 68, 0.5);
        color: #cdd6f4;
        border: 1px solid rgba(202, 158, 230, 0.2);
        border-radius: 8px;
        padding: 8px 12px;
        margin-bottom: 10px;
      }

      #input:focus {
        border-color: #ca9ee6;
        box-shadow: 0 0 4px rgba(202, 158, 230, 0.5);
      }

      #scroll { margin-top: 5px; }
      #text { color: #cdd6f4; margin-left: 10px; }

      #entry {
        padding: 8px;
        border-radius: 8px;
        transition: all 0.1s ease-in-out;
      }

      #entry:selected {
        background-color: rgba(202, 158, 230, 0.3);
        outline: none;
      }

      #entry:selected #text {
        color: #ca9ee6;
        font-weight: bold;
      }
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
      * { background-image: none; box-shadow: none; }
      window { background-color: rgba(30, 30, 46, 0.85); }
      button, button:focus {
        background-color: rgba(49, 50, 68, 0.5);
        color: #cdd6f4;
        border: 2px solid rgba(202, 158, 230, 0.2);
        border-radius: 12px;
        margin: 15px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
        transition: all 0.2s ease-in-out;
        outline: none;
      }
      button:active, button:hover {
        background-color: rgba(202, 158, 230, 0.3);
        border-color: #ca9ee6;
        color: #1e1e2e;
      }
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

  # ----------------------------------------------------------------------------
  # 👑 SECTION 11: Home Manager 核心維護宣告
  # ----------------------------------------------------------------------------
  programs.home-manager.enable = true;
}
