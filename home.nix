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
  # 📦 SECTION 2: 個人軟體包依賴代管 (User-level Packages)
  # ----------------------------------------------------------------------------
  home.packages = with pkgs; [
    # 🦀 Rust 現代化 CLI 刀組 (Rewrite It In Rust)
    ripgrep             # 宇宙最快純文字搜尋引擎，Neovim/Telescope 核心
    fd                  # 簡單、快速且預設忽略 gitignore 的尋找工具
    dust                # 用直觀樹狀圖與百分比顯示硬碟佔用的工具 (指令為 dust)
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
  # 🐚 SECTION 3: Zsh 終端 Shell 與 Antidote 外掛管理機制
  # ----------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll   = "ls -l";
      g    = "git";
      # 🎯 終極防線：讀取本地環境變數 $NIX_PROFILE，若無設定則預設以 pve-profile 安全降維防護
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
      dls = "head -n 1 ~/.local/share/direnv/allow/* 2>/dev/null";
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
  # 🎨 SECTION 4: Starship 現代化跨 Shell 提示字元（Prompt）設定
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
  # 📝 SECTION 5: Neovim 編輯器全權代管與配置
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
  # 🛠️ SECTION 6: 現代化效能工具
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
  # 🖥️ SECTION 7: Wayland 平鋪式視窗管理器 Sway 宇宙與 Waybar 核心宣告
  # ----------------------------------------------------------------------------
  programs.waybar = {
    enable = true;
    # 🎯 完美對齊最新的 targets 陣列 API，徹底消除編譯警告！
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

      # 🎯 關機選單按鈕：宣告 wlogout
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

      /* ──────────────────────────────────────────────────────────
         🎯 托盤與網路圖示呼吸防線（物理拉開間距）
         ────────────────────────────────────────────────────────── */

      /* 1. 托盤外圍區塊：與最右邊緣拉開 12px 的高雅距離 */
      #tray {
        margin-right: 12px;
        padding: 0 6px;
      }

      /* 2. 托盤內部的每一個圖示（鍵盤、網路等）：左右保持大呼吸空間，徹底告別擁擠 */
      #tray > * {
        padding: 0 8px;
        margin: 0 4px;
      }

      /* 🎯 電源按鈕專屬美學 */
      #custom-power {
        color: #f38ba8;         /* 採用 Catppuccin 經典的草莓紅，顯眼且高雅 */
        font-size: 14px;        /* 稍微放大一點點 */
        padding: 0 12px;        /* 左右按鈕內距 */
        margin: 4px 4px;        /* 物理外距，防止和 clock 擠在一起 */
        background-color: rgba(243, 139, 168, 0.15); /* 淡淡的紅色半透明背景 */
        border-radius: 6px;     /* 圓角與 workspaces 保持一致 */
      }

      /* 滑鼠滑過去時，背景加深 */
      #custom-power:hover {
        background-color: rgba(243, 139, 168, 0.3);
      }
    '';
  };

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4"; terminal = "ghostty"; menu = "dmenu_run";
      keybindings = let mod = modifier; in pkgs.lib.mkOptionDefault {
        "${mod}+Return" = "exec ${terminal}"; "${mod}+d" = "exec ${menu}"; "${mod}+Shift+q" = "kill"; "${mod}+Shift+c" = "reload";
        "${mod}+b" = "splith"; "${mod}+v" = "splitv"; "${mod}+e" = "layout toggle split"; "${mod}+w" = "layout tabbed";
        "${mod}+m" = "fullscreen toggle"; "${mod}+Shift+space" = "floating toggle";
        "${mod}+h" = "focus left"; "${mod}+j" = "focus down"; "${mod}+k" = "focus up"; "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left"; "${mod}+Shift+j" = "move down"; "${mod}+Shift+k" = "move up"; "${mod}+Shift+l" = "move right";
      };
      # 🎯 滑鼠與觸控板的終極硬體設定
      input = {
        # 1. 針對所有實體滑鼠 (pointer) 的設定
        "type:pointer" = {
          # 啟動自然捲動（向上滾動時頁面向上，類似 macOS/手機滑動手感，預設為 disabled）
          natural_scroll = "enable";

          # 關閉滑鼠加速（Flat），這對寫 Code 定位或射擊遊戲極度重要，手感會完全線性一對一
          accel_profile = "flat";

          # 指標靈敏度速度調整（範圍 -1.0 到 1.0，0 為不改變）
          pointer_accel = "0.6";
        };

        # 2. 針對所有筆電觸控板 (touchpad) 的設定
        "type:touchpad" = {
          natural_scroll = "enabled";  # 雙指滑動自然捲動
          tap = "enabled";             # 輕觸代表點擊（不用每次都用力按下去）
          middle_emulation = "enabled";# 左右鍵同時按代表滑鼠中鍵
        };
      };
      startup = [
        { command = "fcitx5 -d --replace"; always = true; }
        { command = "swaybg -i ${pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath} -m fill"; always = true; }
      ];
      # 🎯 物理超渡 Sway 自帶的底部狀態列
      bars = [ ];
    };
  };

  # 🎨 完美的 GTK 視覺防線
  gtk = {
    enable = true;

    # 🎯 啟用 Adwaita 圖示主題，徹底解決 nm-applet 圖示遺失問題
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    # (選配) 如果您想要乾淨的 GTK 3 主題
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  services.network-manager-applet.enable = true; # Sway 網路狀態欄位

  # ----------------------------------------------------------------------------
  # 🎨 programs.wlogout: 原生六宮格代管（對稱美學，完美適配實體主機！）
  # ----------------------------------------------------------------------------
  programs.wlogout = {
    enable = true;

    # 🎯 讓 Nix 核心自動序列化，100% 乾淨無瑕、完全無污染的 6 顆按鈕配置
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

    # 🎯 完整的 6 按鈕 CSS 樣式與圖示注入，完美對齊
    style = ''
      * {
        background-image: none;
        box-shadow: none;
      }

      window {
        background-color: rgba(30, 30, 46, 0.85); /* 磨砂玻璃感底色 */
      }

      /* 預設狀態與鍵盤焦點：維持和諧的深灰色 */
      button,
      button:focus {
        background-color: rgba(49, 50, 68, 0.5);
        color: #cdd6f4;
        border: 2px solid rgba(202, 158, 230, 0.2);
        border-radius: 12px;
        margin: 15px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
        transition: all 0.2s ease-in-out;
        outline: none; /* 移除藍色焦點框 */
      }

      /* 僅在滑鼠懸停 (hover) 或點擊 (active) 時優雅亮起薰衣草紫 */
      button:active,
      button:hover {
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
  # 🎨 wlogout 磨砂玻璃與圓角高雅主題（完全回歸原廠預設版，不自訂 layout）
  # ----------------------------------------------------------------------------
  # xdg.configFile."wlogout/style.css".text = ''
  #   * {
  #     background-image: none;
  #     box-shadow: none;
  #   }
  #
  #   window {
  #     background-color: rgba(30, 30, 46, 0.85); /* 磨砂玻璃感底色 */
  #   }
  #
  #   /* 預設狀態與鍵盤焦點：維持和諧的深灰色 */
  #   button,
  #   button:focus {
  #     background-color: rgba(49, 50, 68, 0.5);
  #     color: #cdd6f4;
  #     border: 2px solid rgba(202, 158, 230, 0.2);
  #     border-radius: 12px;
  #     margin: 15px;
  #     background-repeat: no-repeat;
  #     background-position: center;
  #     background-size: 25%;
  #     transition: all 0.2s ease-in-out;
  #     outline: none; /* 移除藍色焦點框 */
  #   }
  #
  #   /* 僅在滑鼠懸停 (hover) 或點擊 (active) 時優雅亮起薰衣草紫 */
  #   button:active,
  #   button:hover {
  #     background-color: rgba(202, 158, 230, 0.3);
  #     border-color: #ca9ee6;
  #     color: #1e1e2e;
  #   }
  #
  #   #lock { background-image: url("${pkgs.wlogout}/share/wlogout/icons/lock.png"); }
  #   #logout { background-image: url("${pkgs.wlogout}/share/wlogout/icons/logout.png"); }
  #   #suspend { background-image: url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"); }
  #   #hibernate { background-image: url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"); }
  #   #shutdown { background-image: url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"); }
  #   #reboot { background-image: url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"); }
  # '';
  #
  # 🎯 物理防線：用 builtins.toJSON 讓 Nix 引擎自己去編譯生成 JSON，完全跳過手寫符號的雷區
  # xdg.configFile."wlogout/layout".text = builtins.toJSON [
  #   {
  #     label = "lock";
  #     action = "swaylock -f -c 11111b";
  #     text = "Lock";
  #     keybind = "l";
  #   }
  #   {
  #     label = "logout";
  #     action = "swaymsg exit";
  #     text = "Logout";
  #     keybind = "e";
  #   }
  #   {
  #     label = "shutdown";
  #     action = "systemctl poweroff";
  #     text = "Shutdown";
  #     keybind = "p";
  #   }
  #   {
  #     label = "reboot";
  #     action = "systemctl reboot";
  #     text = "Reboot";
  #     keybind = "r";
  #   }
  # ];

  # ----------------------------------------------------------------------------
  # 📝 SECTION 8: 全域代碼規範：由 Home Manager 統一管理的全域 .editorconfig 宣告
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

  # ----------------------------------------------------------------------------
  # 🌐 SECTION 9: SSH 用戶端與自動跳轉拓撲 (SSH Config IaC)
  # ----------------------------------------------------------------------------
  programs.ssh = { enableDefaultConfig = false; settings."*" = { Compression = "yes"; ServerAliveInterval = 60; }; };

  # ----------------------------------------------------------------------------
  # 👑 SECTION 10: Home Manager 自我維護機制
  # ----------------------------------------------------------------------------
  programs.home-manager.enable = true;
}
