# ==============================================================================
# ❄️ National Kaohsiung University of Science and Technology - Workstation Config
# 🛠️ System-level Configuration (configuration.nix)
# ==============================================================================

{ config, pkgs, lib, ... }:

{
  # 🔌 SECTION 1: 外部模組路徑引入 (Declarative Imports)
  imports = [
    ./hardware-configuration.nix
    ./local.nix  # 🎯 核心防線：Hostname 將由這個留在本地的檔案宣告
    ./packages.nix
    ./users.nix
  ];

  # ⚙️ SECTION 2: 引導加載器與 Linux 核心內核配置 (Bootloader & Kernel)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ ];

  # 🌐 SECTION 3: 網路架構 (主機名稱已移至本地硬體驱动檔設定)
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
  # ⌨️ SECTION 5: Fcitx5 輸入法框架與 Rime (中州韻) 核心宣告 (Input Method)
  # ----------------------------------------------------------------------------
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-rime
    ];
  };

  # ----------------------------------------------------------------------------
  # 🖥️ SECTION 6: 圖形架構基礎、視窗管理器與 XServer 關閉 (Display & XServer)
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
  # 📡 SECTION 7: 藍牙硬體與背景管理控制模組 (Bluetooth Infrastructure)
  # ----------------------------------------------------------------------------
  # 🎯 啟用 Linux 官方 BlueZ 藍牙核心協議棧
  hardware.bluetooth.enable = true;

  # 🎯 啟用 Blueman 背景 D-Bus 服務，確保不依賴龐大桌面元件即可全權調配藍牙
  services.blueman.enable = true;

  # ----------------------------------------------------------------------------
  # 🎛️ SECTION 8: 視窗通道理順 (Graphics Portal)
  # ----------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  services.printing.enable = true;

  # ----------------------------------------------------------------------------
  # 🔊 SECTION 9: 現代化 PipeWire 音訊架構配置 (Audio System)
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
  # 𔔁 SECTION 10: 現代化 Nerd Fonts 字型與圖示全域補全 (Fonts Infrastructure)
  # ----------------------------------------------------------------------------
  fonts = {
    packages = with pkgs; [
      font-awesome # 🎯 Waybar 常用圖示庫
      noto-fonts-cjk-sans
      nerd-fonts.symbols-only # 🎯 終極圖示救星：只抓符號不抓整套大字型，最省空間且 100% 覆蓋所有 Nerd Font 符號
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # ----------------------------------------------------------------------------
  # 🔐 SECTION 11: 系統安全增強、Tailscale 與 雜項環境變數 (Security & System Global)
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
  # 🔄 SECTION 12: Home Manager 全域系統級注入與 Shell 鎖定 (Home Manager Glue)
  # ----------------------------------------------------------------------------
  home-manager.users.wmt = import ./home.nix;
  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  system.stateVersion = "26.05";
}
