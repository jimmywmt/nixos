{ pkgs, ... }:

{
  users.users."wmt" = {
    isNormalUser = true;
    description = "wmt";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
}
