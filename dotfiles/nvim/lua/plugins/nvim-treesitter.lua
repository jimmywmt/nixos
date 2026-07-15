-- nvim-treesitter 是一個用來提供語法高亮和代碼折疊的插件，它支持多種語言

return {
	"nvim-treesitter/nvim-treesitter",
	-- 🎯 核心修正 1：在 NixOS 下物理移除 build = ":TSUpdate"，不讓它在背景動態編譯
	config = function()
		-- 🎯 核心修正 2：解決「module 'nvim-treesitter.configs' not found」天坑
		-- 直接呼叫頂層模組本體
		require("nvim-treesitter").setup({
			-- 🎯 核心修正 3：在 NixOS 下保持空的或 nil。
			-- 語法解析器改由 home.nix 統一硬化注入，防範找不到 C 工具鏈的閃退天坑
			ensure_installed = {},
			auto_install = false,

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
			},
		})
	end,
}
