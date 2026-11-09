# 📄 機器獨用檔通用 import（清單 = ../local-files.txt，單一事實來源）
#
# 每個條目：本機有實體檔就用實體檔；沒有就 fallback 到 <名稱>.example 範本
# （讓新機器 clone 下來、還沒建實體檔時 nix eval 不會炸）。
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

  pick = name:
    let
      real = ./.. + "/${name}";
      example = ./.. + "/${name}.example";
    in
    if builtins.pathExists real
    then real
    else if builtins.pathExists example
    then example
    else builtins.throw
      "local-files.txt 列了 ${name}，但這台既沒有 ${name} 也沒有 ${name}.example（請 cp 範本後修改）";
in
{
  imports = map pick entries;
}
