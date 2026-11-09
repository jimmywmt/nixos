# /etc/nixos/local.nix
{ config, pkgs, ... }: {

  # 1. 宣告這台機器獨一無二的尊號
  networking.hostName = "wmt-amd-nixos";

  # 2. 強行注入系統全域變數，引導 Zsh 別名去咬合對應的 Flake 樣板
  environment.sessionVariables = {
    NIX_PROFILE = "gpu-profile";
  };

  fileSystems."/mnt/steam-storage" = {
    device = "/dev/disk/by-label/steam-storage";
    fsType = "ext4";
    options = [ "defaults" "nofail" "noatime" ]; # noatime 減少讀寫磨損，nofail 確保硬碟離線時系統不卡死
  };

  # 3. 本機專屬：AMD Radeon RX 5700 XT 顯卡硬體監控特化 (btop)
  home-manager.users.wmt = {
    programs.btop = {
      package = pkgs.btop.override { rocmSupport = true; };
      settings = {
        shown_boxes = "cpu gpu0 mem net proc";
        show_gpu_info = "On";
        shown_gpus = "amd";
        custom_gpu_name0 = "Radeon RX 5700 XT";
      };
    };
  };
}
