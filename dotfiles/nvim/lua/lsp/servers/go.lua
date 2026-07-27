-- lua/lsp/servers/go.lua
return function(common)
	local function root_dir(fname)
		local dir = fname
		while dir and dir ~= "" do
			local p = dir:match("(.*/)")
			if not p then
				break
			end
			-- 現代 Neovim 0.10+ 推薦使用 vim.uv 代替 vim.loop
			local uv = vim.uv or vim.loop
			if uv.fs_stat(p .. "go.work") or uv.fs_stat(p .. "go.mod") or uv.fs_stat(p .. ".git") then
				return p
			end
			dir = p:sub(1, #p - 1):match("(.*/)")
		end
		return vim.loop.cwd()
	end

	common.autostart({
		name = "gopls",
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork" },
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
