{ pkgs, ... }:

{
  users.users."wmt" = {
    isNormalUser = true;
    description = "wmt";
    shell = pkgs.zsh;
    autoSubUidGidRange = true;
    linger = true;
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
}
