-- lua/lsp/servers/go.lua
return function(common)
	local function root_dir(fname)
		-- 使用 Neovim 內建的 vim.fs.root，精準且效能極高
		-- 優先找 go.work (Workspace)，再找 go.mod 或 .git
		local root = vim.fs.root(fname, { "go.work", "go.mod", ".git" })

		-- 如果真的都找不到 (例如孤立的單一檔案)，才降級使用當前 CWD
		return root or vim.loop.cwd()
	end

	common.autostart({
		name = "gopls",
		cmd = { "gopls" },
		filetypes = { "go", "gomod" },
		root_dir = root_dir,
		settings = {
			gopls = {
				staticcheck = true,
				gofumpt = true,
				usePlaceholders = true,
			},
		},
	})
end
