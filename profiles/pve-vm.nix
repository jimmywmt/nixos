{ config, pkgs, ... }: {
  # ⚙️ PVE 虛擬化平台的所有肉身驅動，死死鎖在這裡，絕不外流！
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.xserver.videoDrivers = [ "qxl" ];
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "virtio_blk" "virtio_net" ];

  # 輕量登入
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd}/bin/agreety --cmd ${pkgs.sway}/bin/sway";
      user = "greeter";
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER = "pixman";
  };
}
