{ config, pkgs, lib, ... }: {

  # ============================================================================
  # 🚀 核心排程優化與平行宇宙 (Specialisation 防線)
  # ============================================================================

  # ⚖️ 日常預設宇宙：進 Sway 工作，吃標準最新穩定核心
  # 🎯 關鍵微調：改用 lib.mkDefault 降低優先權，為子宇宙留出絕對的覆蓋通道
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # 🎮 點火遊戲特化平行宇宙：開機選單選這個，才會物理換心
  specialisation = {
    gaming.configuration = {
      # 🎯 雙重保險：配合上面的 mkDefault，這裡用 mkForce 強行拉高權重，物理超渡衝突
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_xanmod;
    };
  };

  # ============================================================================
  # 🔌 獨立顯示卡硬體驅動矩陣 (AMD / NVIDIA 雙棲切換)
  # ============================================================================

  # 🏎️ 流派 A：AMD 顯示卡與 CPU 微碼核心優化 (目前作用中)
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd # 👑 ROCm 本地 AI 算力底座
  ];

  # 🟢 流派 B：NVIDIA 顯示卡官方開源驅動模組 (預設註解，若換卡請解鎖下方 8 行，並註釋掉上方 AMD 流派)
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   open = true;              # 使用 NVIDIA 官方開源核心模組 (核心安全防線)
  #   nvidiaSettings = true;
  # };
  # # 註：若 NVIDIA 機台搭載 AMD CPU，請手動解鎖下方微碼更新：
  # # hardware.cpu.amd.updateMicrocode = true;

  # ----------------------------------------------------------------------------

  # 🎨 全域硬體圖形加速底座 (32位元相容，Steam 執行基石)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ============================================================================
  # 📺 登入管理調度與遊戲矩陣 (0% GNOME 贅肉，純粹的 Sway + Steam 雙棲入口)
  # ============================================================================

  # 🧠 獨立啟動 GDM 調度大腦
  services.displayManager.gdm.enable = true;

  # 🎯 啟動 Feral GameMode 服務系統總線
  programs.gamemode.enable = true;

  # 🎮 蒸汽動力源：開啟 Steam 官方優化與 Gamescope 獨立微縮合成器
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # 開放 Steam 遠端串流
    # gamescopeSession.enable = true; # 🔥 關鍵：直接為 GDM 齒輪註冊「Steam 大螢幕模式」入口

    # 🎯 將 MangoHud 與 GameMode 塞入 Steam 的 FHS 運行沙盒
    extraPackages = with pkgs; [
      gamemode
      # mangohud
    ];
  };

  # 原生 Wayland 管道理順環境變數
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
