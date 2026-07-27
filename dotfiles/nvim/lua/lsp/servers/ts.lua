-- lua/lsp/servers/ts.lua
-- TypeScript / JavaScript / Vue LSP (ts_ls + Vue TS Plugin)
return function(common)
	local util = require("lspconfig.util")

	-- 動態定位 NixOS 系統安裝的 @vue/language-server 路徑
	local function get_vue_plugin_path()
		local vue_bin = vim.fn.resolve(vim.fn.exepath("vue-language-server"))
		if vue_bin == "" then
			return nil
		end

		-- 從 bin/vue-language-server 反推 lib/node_modules/@vue/language-server
		local pkg_root = vim.fn.fnamemodify(vue_bin, ":h:h")
		local plugin_path = pkg_root .. "/lib/node_modules/@vue/language-server"

		if vim.fn.isdirectory(plugin_path) == 1 then
			return plugin_path
		end
		return nil
	end

	-- 設定 Vue 插件 (Hybrid Mode)
	local init_options = {}
	local vue_plugin_path = get_vue_plugin_path()

	if vue_plugin_path then
		init_options.plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vue_plugin_path,
				languages = { "vue" },
			},
		}
	end

	local base_cfg = {
		name = "ts_ls",
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
		single_file_support = true,
		on_attach = common.on_attach,
		capabilities = common.capabilities,
		init_options = init_options,
		settings = {
			typescript = {
				tsserver = {
					useSyntaxServer = false,
				},
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		},
	}

	vim.api.nvim_create_autocmd("FileType", {
		pattern = base_cfg.filetypes,
		callback = function(ev)
			if #vim.lsp.get_clients({ name = base_cfg.name, bufnr = ev.buf }) > 0 then
				return
			end

			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local uv = vim.uv or vim.loop

			local root
			if fname ~= "" then
				root = util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname)
			end
			root = root or uv.cwd()

			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
			}))
		end,
	})
end
