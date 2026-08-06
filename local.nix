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
}
