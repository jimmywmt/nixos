-- blink.cmp: 基於 Rust 的極速補全引擎
-- 取代 nvim-cmp, cmp-buffer, cmp-path, cmp-nvim-lsp, lspkind
return {
	"saghen/blink.cmp",
	-- 使用 release 版本，確保穩定
	version = "*",

	-- [重要] 既然您是 Rust 專家，我們讓它在安裝時自動編譯，確保最佳效能
	-- build = "cargo build --release",

	dependencies = {
		"rafamadriz/friendly-snippets", -- 豐富的 Snippet 庫
	},

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'default' preset:
		--   <C-space>: Show menu
		--   <CR>: Accept
		--   <C-e>: Cancel
		--   <C-p>/<C-n>: Up/Down
		-- 'super-tab' preset:
		--   <Tab>: Accept / Select Next
		--   <S-Tab>: Select Prev
		keymap = {
			preset = "super-tab",
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
		},

		appearance = {
			-- 設定 Nerd Font 圖示
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},

		-- 來源設定：整合 LSP, Path, Snippets, Buffer
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		snippets = { preset = "default" },

		-- 簽名提示 (取代 lsp_signature.nvim)
		signature = { enabled = true },

		-- 文件視窗設定
		completion = {
			menu = {
				-- 1. 補全選單的邊框
				border = "rounded", -- 選項：'single', 'double', 'rounded', 'solid', 'shadow'
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = {
					-- 2. 詳細文件視窗的邊框
					border = "rounded",
				},
			},
			-- 類似 nvim-cmp 的 ghost_text (灰字預覽)
			ghost_text = { enabled = true },
		},

		-- 3. (選用) 函數參數提示的邊框
		signature = {
			window = {
				border = "rounded",
			},
		},
	},
	opts_extend = { "sources.default" },
}
