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
  ];

  # ----------------------------------------------------------------------------
  # ⚙️ SECTION 2: 引導載入器與 Linux 核心內核配置 (Bootloader & Kernel)
  # ----------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # 載入 Linux 核心原生 Switch 驅動（0 常駐進程，核心層直接處理）和 Xbox 手把驅動
  boot.kernelModules = [ "uhid" "hid_nintendo" "hid_xpadneo" ];

  # ----------------------------------------------------------------------------
  # 🌐 SECTION 3: 網路架構與連線管理 (Networking & NetworkManager)
  # ----------------------------------------------------------------------------
  networking.networkmanager.enable = true;

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
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
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
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.tailscale.enable = true;
  services.udisks2.enable = true;

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

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  # ----------------------------------------------------------------------------
  # 🔄 SECTION 11: Home Manager 全域系統級注入與 Shell 鎖定 (Home Manager Glue)
  # ----------------------------------------------------------------------------
  home-manager.users.wmt = import ./home.nix;
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
