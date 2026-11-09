{ pkgs, ... }:

{
  # 🎯 修復 Elephant Websearch 前綴權重：當使用者輸入自訂搜尋前綴 (例如 'euc ') 時，
  # 將該項目的權重提升至 100,000 (最高優先級)，確保永遠名列第一首選，不被其他應用程式模糊比對干擾
  nixpkgs.overlays = [
    (final: prev: {
      elephant = prev.elephant.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace internal/providers/websearch/setup.go \
            --replace-fail 'Score:      int32(15 - k),' 'Score: func() int32 { if prefix != "" && v.Prefix == prefix { return 100000 }; return int32(15 - k) }(),' \
            --replace-fail 'Subtext:    "",' 'Subtext: func() string { if prefix != "" && v.Prefix == prefix { t := strings.TrimSpace(strings.TrimPrefix(query, prefix)); if t != "" { return fmt.Sprintf("查詢：%s", t) } else { return "歐路字典快速查詞" } }; return "" }(),'
        '';
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    ghostty.terminfo
  ];
}
