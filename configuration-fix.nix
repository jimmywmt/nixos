# 這台 AMD 電腦的 configuration-fix.nix
{ pkgs, ... }: {
  hardware.enableAllFirmware = true;
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "pcie_aspm=off"
    "amd_pstate=active" # 🚀 AMD CPPC 原生自主動態調頻 (EPP)，毫秒級切換延遲且更省電
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-41.10.7"
  ];
}
