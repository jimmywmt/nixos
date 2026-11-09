{ config, pkgs, lib, ... }: {

  # ============================================================================
  # 🚀 核心排程優化與平行宇宙 (Specialisation 防線)
  # ============================================================================

  # ⚖️ 日常預設宇宙：進 Sway 工作，吃標準最新穩定核心
  # 🎯 關鍵微調：改用 lib.mkDefault 降低優先權，為子宇宙留出絕對的覆蓋通道
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # 🎮 點火遊戲特化平行宇宙：開機選單選這個，才會物理換心並拔除所有干擾
  specialisation = {
    gaming.configuration = {
      # 🎯 雙重保險：配合上面的 mkDefault，這裡用 mkForce 強行拉高權重，物理超渡衝突
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_xanmod;

      # 🚀 1. CPU 效能調度器：鎖定最高時脈 (Performance)，防止場景切換時 CPU 降頻掉幀
      powerManagement.cpuFreqGovernor = lib.mkForce "performance";

      # ⚡ 2. 核心防卡頓：禁用 Linux 核心對 Split Lock 的限速懲罰
      # 原理：許多 3A 大作/Steam 轉譯層會觸發 split lock，Linux 預設會強制限速該程序導致掉幀卡頓 (Stuttering)
      boot.kernelParams = [ "split_lock_mitigate=0" ];

      # 🖨️ 3. 關閉辦公與外設周邊服務（釋放常駐記憶體與 D-Bus 通訊開銷）
      services.printing.enable = lib.mkForce false;      # 關閉 CUPS 印表機服務
      services.avahi.enable = lib.mkForce false;         # 關閉 mDNS 區域網路廣播
      hardware.sane.enable = lib.mkForce false;          # 關閉 掃描器驅動架構
      services.pcscd.enable = lib.mkForce false;         # 關閉 智慧卡/晶片讀卡機服務

      # 📦 4. 關閉容器與開發背景服務
      virtualisation.podman.enable = lib.mkForce false;  # 關閉 Podman / Docker 容器引擎

      # 🧹 5. 關閉系統背景定時任務（防止遊戲進行中背景觸發 I/O 造成瞬間卡頓）
      nix.gc.automatic = lib.mkForce false;              # 暫停每日 Nix 自動垃圾清理 (GC)
      systemd.user.timers.direnv-prune.enable = lib.mkForce false; # 暫停 direnv 清理任務

      # 🚫 6. 關閉背景無用 Daemon 與網路穿透（降低背景輪詢與 D-Bus 負擔，物理網卡直通連線）
      services.tumbler.enable = lib.mkForce false;       # 關閉 檔案管理器背景縮圖生成服務
      services.gvfs.enable = lib.mkForce false;          # 關閉 GNOME 虛擬檔案系統 (網路芳鄰/垃圾桶抽象層)
      services.openssh.enable = lib.mkForce false;       # 關閉 SSH 伺服器
      services.tailscale.enable = lib.mkForce false;     # 關閉 Tailscale VPN 虛擬網卡與節點輪詢

      # 🖥️ 7. 桌面體驗特化 (Home Manager 層級覆寫)
      home-manager.users.wmt = {
        # 🎮 避免遊戲中黑畫面：關閉 5 分鐘閒置自動鎖屏與關螢幕
        # 原因：使用手把玩單機 3A 大作或看過場動畫時沒碰鍵盤滑鼠，會被誤判閒置強制鎖定
        services.swayidle.enable = lib.mkForce false;

        # 🎨 保持遊戲原生畫質與色溫：關閉夜間自動抗藍光/螢幕泛黃
        services.wlsunset.enable = lib.mkForce false;
      };
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

  # 1. 關閉 GDM 與多餘的 GNOME 桌面服務
  services.displayManager.gdm.enable = false;

  # 2. 啟用 ReGreet
  programs.regreet = {
    enable = true;
    # 可選：自訂字型、主題、游標或桌布
    settings = {
      background = {
        path = ./wallpapers/pexels-ahmetyuksek-38632135.jpg;
        fit = "Cover";
      };
      GTK = {
        # theme_name = "Adwaita-dark";
        # icon_theme_name = "Papirus-Dark";
      };
    };
  };

  # 3. 確保 PAM 在透過 greetd 登入時自動解鎖 gnome-keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # 🎯 啟動 Feral GameMode 全域服務系統總線 (支援 Steam、Heroic、獨立遊戲或任何 gamemoderun)
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
        inhibit_screensaver = 1;
        disable_splitlock = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        # 🎯 自動適配：若啟用 NVIDIA 驅動則預設為 card0，AMD 實體機則對應 card1
        gpu_device = if (builtins.elem "nvidia" config.services.xserver.videoDrivers) then 0 else 1;
        nv_powermizer_mode = 1;         # 🟢 NVIDIA 專屬：1 = Prefer Maximum Performance (鎖定最高效能)
        amd_performance_level = "high"; # 🏎️ AMD 專屬：強制拉滿時脈
      };
    };
  };

  # 🎮 蒸汽動力源：開啟 Steam 官方優化與 Gamescope 獨立微縮合成器
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # 開放 Steam 遠端串流
    protontricks.enable = true;    # 🍷 Winetricks / Proton 補丁神器 (修復字型、DLL、DirectX)
    # gamescopeSession.enable = true; # 🔥 關鍵：直接為 GDM 齒輪註冊「Steam 大螢幕模式」入口

    # 🎯 將 MangoHud 與 GameMode 塞入 Steam 的 FHS 運行沙盒
    # extraPackages = with pkgs; [
      # gamemode
      # mangohud
    # ];
  };

  # ⚔️ 實體機與遊戲桌面附加軟體 (Heroic, AMD GPU 監控)
  environment.systemPackages = with pkgs; [
    heroic
    amdgpu_top
  ];

  # 原生 Wayland 管道理順環境變數
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";

    # 🔥 關鍵：讓 Heroic 與所有 Wine/Proton 工具自動偵測 Steam 下載好的 Proton-GE
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.local/share/Steam/compatibilitytools.d";
  };
}
