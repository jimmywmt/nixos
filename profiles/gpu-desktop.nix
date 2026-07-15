{ config, pkgs, ... }: {

  # ============================================================================
  # 🔌 獨立顯示卡硬體驅動矩陣 (AMD / NVIDIA 雙棲切換)
  # ============================================================================

  # 🏎️ 流派 A：AMD 顯示卡與 CPU 微碼核心優化 (目前作用中)
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd # 👑 ROCm 本地 AI 算力底座 (未來跑本地 LLM 必備)
    amdvlk               # AMD 官方 Vulkan 核心
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

  # 🎨 全域硬體圖形加速底座 (32位元相容相容，Steam 執行基石)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ============================================================================
  # 📺 登入管理調度與遊戲矩陣 (0% GNOME 贅肉，純粹的 Sway + Steam 雙棲入口)
  # ============================================================================

  # 🧠 獨立啟動 GDM 調度大腦
  services.displayManager.gdm.enable = true;

  # 🎮 蒸汽動力源：開啟 Steam 官方優化與 Gamescope 獨立微縮合成器
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # 開放 Steam 遠端串流 (允許 Mac 遠端借算力)
    gamescopeSession.enable = true; # 🔥 關鍵：直接為 GDM 齒輪註冊「Steam 大螢幕模式」入口
  };

  # 原生 Wayland 管道理順環境變數
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
