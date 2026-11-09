# 💻 機器獨用 app（這台：wmt-amd-nixos；不同步、永不推 GitHub）
# 寫法看旁邊的 local-apps.nix.example 範本；改完 git add ＋ nr 生效。
{ pkgs, ... }:
{
  # ── 本機專屬：AMD Radeon RX 5700 XT 顯卡硬體監控特化 (btop) ────────
  home-manager.users.wmt.programs.btop = {
    package = pkgs.btop.override { rocmSupport = true; };
    settings = {
      shown_boxes = "cpu gpu0 mem net proc";
      show_gpu_info = "On";
      shown_gpus = "amd";
      custom_gpu_name0 = "Radeon RX 5700 XT";
    };
  };

  # ── CLI 工具（走 nix；同 home.nix 的 packages，但不會同步）───────────
  # home-manager.users.wmt.home.packages = [
  #   pkgs.ffmpeg
  # ];

  # ── 機器獨用服務（systemd 使用者服務，登入即自動啟動）───────────────
  # systemd.user.services.example = {
  #   Unit.Description = "範例服務";
  #   Service.ExecStart = "${pkgs.example}/bin/example";
  #   Install.WantedBy = [ "default.target" ];
  # };
}
