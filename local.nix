# 🔧 機器獨用硬體與環境設定（這台：wmt-amd-nixos；不同步、永不推 GitHub）
#
# 這個檔案只放：
#   1. profile 選擇（NIX_PROFILE）
#   2. 硬體掛載（fileSystems）
#
# 機器獨用的「身分」請放 hostname.nix，「軟體」請放 local-apps.nix。
{ config, pkgs, ... }: {

  # 1. 引導 Zsh 別名去咬合對應的 Flake 樣板
  environment.sessionVariables = {
    NIX_PROFILE = "gpu-profile";
  };

  # 2. 本機硬碟掛載（steam-storage）
  fileSystems."/mnt/steam-storage" = {
    device = "/dev/disk/by-label/steam-storage";
    fsType = "ext4";
    options = [ "defaults" "nofail" "noatime" ]; # noatime 減少讀寫磨損，nofail 確保硬碟離線時系統不卡死
  };
}
