# ==============================================================================
# ❄️ National Kaohsiung University of Science and Technology - Workstation Config
# 🛠️ System-level Configuration (configuration.nix)
# ==============================================================================

{ config, pkgs, lib, ... }:

{
  # ----------------------------------------------------------------------------
  # 🔌 SECTION 1: 外部模組路徑引入 (Declarative Imports)
  # ----------------------------------------------------------------------------
  imports = [
    ./hardware-configuration.nix
    ./local.nix  # 🎯 核心防線：Hostname 將由這個留在本地的檔案宣告
    ./packages.nix
    ./users.nix
  ]
  # 如果目錄下有 configuration-fix.nix 才引入，否則傳回空串列 []
  ++ (if builtins.pathExists ./configuration-fix.nix then [ ./configuration-fix.nix ] else []);

  # ----------------------------------------------------------------------------
  # ⚙️ SECTION 2: 引導載入器與 Linux 核心內核配置 (Bootloader & Kernel)
  # ----------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 2; # 🎯 縮短開機等待倒數 (按任意鍵仍可暫停)
  boot.kernelModules = [ "uhid" "hid_nintendo" "hid_xpadneo" ];

  # 🎯 記憶體防崩潰防線 (zstd 極速壓縮，相當於動態增加 8~16GB 虛擬記憶體，防止遊戲因 OOM 閃退)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # 🚀 核心參數優化 (ZRAM Swappiness 積極壓縮 + Google BBR 網路加速)
  boot.kernel.sysctl = {
    # 🎯 ZRAM 最佳化：積極將冷記憶體壓縮至 ZRAM，保留實體 RAM 作為 Page Cache 與遊戲快取
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;

    # 🎯 Google BBR 擁塞控制演算法：顯著優化 Wi-Fi 封包抗抖動能力，加速 Steam 下載與網路存取
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # ----------------------------------------------------------------------------
  # 🌐 SECTION 3: 網路架構與連線管理 (Networking & NetworkManager)
  # ----------------------------------------------------------------------------
  networking.networkmanager.enable = true;

  # 🎯 LocalSend 跨裝置區網互傳防火牆端口 (TCP/UDP 53317)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  # ----------------------------------------------------------------------------
  # 🗺️ SECTION 4: 地理時區與多語系/本地化環境變數 (Localization & Locale)
  # ----------------------------------------------------------------------------
  time.timeZone = "Asia/Taipei";
  i18n.defaultLocale = "zh_TW.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_TW.UTF-8"; LC_IDENTIFICATION = "zh_TW.UTF-8";
    LC_MEASUREMENT = "zh_TW.UTF-8"; LC_MONETARY = "zh_TW.UTF-8";
    LC_NAME = "zh_TW.UTF-8"; LC_NUMERIC = "zh_TW.UTF-8";
    LC_PAPER = "zh_TW.UTF-8"; LC_TELEPHONE = "zh_TW.UTF-8";
    LC_TIME = "zh_TW.UTF-8";
  };

  # ----------------------------------------------------------------------------
  # 🖥️ SECTION 5: 圖形桌面、視窗管理器與系統套件 (Display & Sway & System Packages)
  # ----------------------------------------------------------------------------
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # 🎯 啟用 Xfce 配置守護進程 (供 Thunar 記住路徑標題風格與設定)
  programs.xfconf.enable = true;

  environment.systemPackages = with pkgs; [
    dmenu
    google-chrome
  ];

  # ----------------------------------------------------------------------------
  # 📡 SECTION 6: 藍牙硬體與背景管理控制模組 (Bluetooth Infrastructure)
  # ----------------------------------------------------------------------------
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # 🎯 專門針對 Xbox 藍牙手把的驅動（自動修復 ERTM、震動與按鍵映射）
  hardware.xpadneo.enable = true;
  # 🎯 確保 udev 權限存在
  hardware.steam-hardware.enable = true;

  # ----------------------------------------------------------------------------
  # 🎛️ SECTION 7: 視窗通道與桌面底層 D-Bus 服務 (Desktop Portals & Services)
  # ----------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk # 🎯 必備：提供 GTK 檔案選取器 (File Chooser Dialog)，解決開檔/存檔卡死
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      sway = {
        default = lib.mkForce [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
  };

  # 🎯 提供虛擬檔案系統 (GVfs) 後端：支援垃圾桶 (trash://) 雙向同步
  services.gvfs.enable = true;

  # 🎯 提供跨應用通用縮圖生成服務 (Tumbler)
  services.tumbler.enable = true;

  # ----------------------------------------------------------------------------
  # 🔊 SECTION 8: 現代化 PipeWire 音訊架構配置 (Audio System)
  # ----------------------------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ----------------------------------------------------------------------------
  # 𔔁 SECTION 9: 現代化 Nerd Fonts 字型與圖示全域補全 (Fonts Infrastructure)
  # ----------------------------------------------------------------------------
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      font-awesome             # 🎯 Waybar 常用圖示庫
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      nerd-fonts.symbols-only  # 🎯 終極圖示救星：只抓符號不抓整套大字型
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      corefonts
      liberation_ttf
      vista-fonts
      # 置入本機字型
      # 🎯 置入本機字型（自動遞迴掃描 ./fonts 底下的所有 .ttf 與 .ttc 檔）
      (runCommand "custom-local-fonts" {} ''
        mkdir -p $out/share/fonts/truetype
        find ${./fonts} -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.TTF" -o -name "*.TTC" \) -exec cp {} $out/share/fonts/truetype/ \;
      '')
    ];
    fontconfig = {
      enable = true;
      subpixel.rgba = "rgb";    # 🎯 34 吋標準 RGB 次像素平滑化
      hinting.style = "slight"; # 🎯 輕微微調，文字邊緣更銳利且保持字型原貌
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "LINE Seed TW_TTF" "Noto Sans CJK TC" ];
        serif = [ "Noto Serif CJK TC" ];
      };
    };
  };

  # 🎯 每次系統 switch 時，先清空舊目錄，再將 /usr/share/fonts 乾淨鏈接到最新 Profile
  system.activationScripts.usrShareFonts = ''
    mkdir -p /usr/share
    rm -rf /usr/share/fonts
    ln -sfn /run/current-system/sw/share/X11/fonts /usr/share/fonts
  '';

  # ----------------------------------------------------------------------------
  # 🔐 SECTION 10: 系統安全、網路服務與 Nix 基礎設施 (Security, SSH, Nix GC)
  # ----------------------------------------------------------------------------
  programs.firefox.enable = false;
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; # 🎯 自動利用 hard link 去除重複檔案，節省磁碟空間
    warn-dirty = false;         # 🎯 關閉每次 git dirty 的警告訊息
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # 👑 nh (Yet Another Nix Helper) - 現代化 NixOS CLI 前端與視覺化工具
  programs.nh = {
    enable = true;
    flake = "/home/wmt/.config/nixos";
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 7d"; # 🎯 智慧清理：永遠為使用者保留至少 5 個歷史世代供回滾
    };
  };

  # 💫 nix-index 與 comma：免安裝隨打即跑任何套件，自帶預先編譯的二進位資料庫
  programs.nix-index-database.comma.enable = true;
  services.earlyoom.enable = true; # 🚨 記憶體耗盡保護，避免大編譯或程式洩漏導致全系統凍結卡死
  services.tailscale.enable = true;
  services.udisks2.enable = true;

  # 🧹 限制系統日誌體積，防止 journal 膨脹過度佔用 SSD
  services.journald.extraConfig = "SystemMaxUse=500M";

  # ⚡ 解除檔案描述符上限 (預防 Steam Esync、大型編譯與 Neovim 多 LSP 撞到 1024 限制)
  systemd.settings.Manager.DefaultLimitNOFILE = "1048576";
  security.pam.loginLimits = [
    { domain = "*"; type = "-"; item = "nofile"; value = "1048576"; }
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # 👑 nix-ld 全域動態連結防線
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc zlib fuse3 alsa-lib libpulseaudio openssl icu libgit2
      gtk3 webkitgtk_4_1 libsoup_3 cairo gdk-pixbuf glib pango harfbuzz
      libnotify libGL mesa libxkbcommon wayland libx11
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # 🛰️ 每日背景自動執行 direnv prune，超渡所有失效的專案列管
  systemd.user.services.direnv-prune = {
    description = "Auto prune dead direnv configurations";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.direnv}/bin/direnv prune";
    };
    wantedBy = [ "default.target" ];
  };

  systemd.user.timers.direnv-prune = {
    description = "Timer for daily direnv pruning";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  # 由 nh.clean 統一接管定期 GC，停止原生過於激進的純時間刪除
  nix.gc.automatic = false;

  # ----------------------------------------------------------------------------
  # 🔄 SECTION 11: Home Manager 全域系統級注入與 Shell 鎖定 (Home Manager Glue)
  # ----------------------------------------------------------------------------
  home-manager.users.wmt = import ./home.nix;
  home-manager.backupFileExtension = "backup"; # 🎯 遇到未納管的現有設定檔時自動更名備份，防範 switch 失敗
  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  # ----------------------------------------------------------------------------
  # 🖨️ SECTION 12: 辦公周邊與周邊硬體防線 (Printing, Scanning & SmartCard)
  # ----------------------------------------------------------------------------
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  # 🎯 啟用 Avahi 背景廣播協議，盲抓區域網路印表機
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # 🎯 啟用 SANE 掃描器驅動架構，並掛載 airscan 免驅協議
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  # 啟用智慧卡底層服務
  services.pcscd.enable = true;

  # ----------------------------------------------------------------------------
  # 📦 SECTION 13: 虛擬化與容器引擎 (Podman Infrastructure)
  # ----------------------------------------------------------------------------
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;                         # 自動建立 docker 別名
    defaultNetwork.settings.dns_enabled = true;  # 容器間 DNS 解析
  };

  system.stateVersion = "26.05";
}
