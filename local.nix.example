# /etc/nixos/local.nix
{ config, pkgs, ... }: {

  # 1. 宣告這台機器獨一無二的尊號
  networking.hostName = "pve-nixos";

  # 2. 強行注入系統全域變數，引導 Zsh 別名去咬合對應的 Flake 樣板
  environment.sessionVariables = {
    NIX_PROFILE = "pve-profile";
  };
}
