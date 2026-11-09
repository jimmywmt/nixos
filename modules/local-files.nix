# 📄 機器獨用檔通用 import（清單 = ../local-files.txt，單一事實來源）
#
# 每個條目：
#   - 本機有實體檔 → 用實體檔
#   - 沒有實體檔但有 <名稱>.example → fallback 到範本（新機器 clone 後、還沒建檔時可用）
#   - 兩者都沒有 → 跳過（不報錯，適合 hardware-configuration.nix 這類「必須各自產生」的檔）
#
# nppush / nppull（zsh 端）讀同一份清單來排除這些檔，所以新增機器獨用檔
# 只需要改 local-files.txt 一行＋配 .example，不用動 nppush / nppull 或本檔。
{ lib, ... }:
let
  # 逐行讀 local-files.txt：砍註解、trim、丟空行
  entries =
    builtins.filter (l: l != "")
    (map (l: lib.trim (builtins.head (lib.splitString "#" l)))
      (lib.splitString "\n" (builtins.readFile ../local-files.txt)));

  # 只 import 存在實體檔或 .example 的條目；兩者都沒有就跳過
  pick = name:
    let
      real = ./.. + "/${name}";
      example = ./.. + "/${name}.example";
    in
    if builtins.pathExists real then real
    else if builtins.pathExists example then example
    else null;

  picked = builtins.filter (x: x != null) (map pick entries);
in
{
  imports = picked;
}
