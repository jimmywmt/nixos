{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    ghostty.terminfo
  ];
}
