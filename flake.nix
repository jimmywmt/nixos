{
  description = "Jimmy's Polyglot Multi-Host NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {

      # 🪐 樣板 A：所有 PVE 虛擬機通用此配置（0% 遊戲與重型桌面代碼殘留）
      pve-profile = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./profiles/pve-vm.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

      # 🏎️ 樣板 B：所有具備獨立顯卡的實體工作站通用此配置（GDM 齒輪 + Steam 滿血通電）
      gpu-profile = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./profiles/gpu-desktop.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

    };
  };
}
