-- lualine.nvim 是一個用來設置狀態欄的插件，它提供了一個簡單的方式來設置狀態欄
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		options = {
			disabled_filetypes = {
				"packer",
				"NvimTree",
			},
			theme = "everforest",
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { "filename" },
			lualine_x = { "encoding", "fileformat", "filetype", "filesize" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
}
