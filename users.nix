{ pkgs, ... }:

{
  users.users."wmt" = {
    isNormalUser = true;
    description = "wmt";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
}
