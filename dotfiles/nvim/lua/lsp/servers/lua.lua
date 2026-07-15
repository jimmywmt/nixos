-- lua/lsp/servers/lua.lua
-- 目標：
-- 1) 以新 API（vim.lsp.start + FileType）啟動 lua-language-server
-- 2) 沿用你的 on_init 邏輯：若不是 NVIM_CONFIG，且專案已有 .luarc{.json,.jsonc}，就不覆蓋
-- 3) 共用 common.on_attach / common.capabilities

return function(common)
	local util = require("lspconfig.util")

	-- 共用 on_init：複製你舊設定的判斷
	local function on_init(client, _)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc"))
			then
				-- 專案本身已提供 luarc，尊重它，不覆蓋
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
			runtime = { version = "LuaJIT" },
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
		})
	end

	-- 基礎 cfg（除了 root_dir，其他可以預先定好）
	local base_cfg = {
		name = "lua_ls",
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		on_attach = common.on_attach,
		capabilities = common.capabilities,
		settings = { Lua = {} },
		on_init = on_init,
		single_file_support = true,
	}

	-- 依 filetype 啟動（新 API 標配）
	vim.api.nvim_create_autocmd("FileType", {
		pattern = base_cfg.filetypes,
		callback = function(ev)
			-- 避免在同一個 buffer 重複啟動
			if #vim.lsp.get_clients({ name = base_cfg.name, bufnr = ev.buf }) > 0 then
				return
			end

			-- 為當前檔案計算 root_dir（優先 .luarc*，再找 .git，最後退回 cwd）
			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local root = util.root_pattern(".luarc.json", ".luarc.jsonc")(fname)
				or util.find_git_ancestor(fname)
				or vim.loop.cwd()

			-- 真的啟動
			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
			}))
		end,
	})
end
