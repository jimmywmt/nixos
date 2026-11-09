-- lua/lsp/servers/nixd.lua
-- Nix 語言伺服器：nixd
-- 提供語法分析、NixOS / Home Manager Option 自動補全與文檔、診斷、跳轉定義
return function(common)
	local util = require("lspconfig.util")

	local profile = vim.env.NIX_PROFILE or "gpu-profile"
	local nixos_config_dir = vim.fn.expand("~/.config/nixos")

	local base_cfg = {
		name = "nixd",
		cmd = { "nixd" },
		filetypes = { "nix" },
		single_file_support = true,
		on_attach = common.on_attach,
		capabilities = common.capabilities,
	}

	-- 自動在 nix 檔案開啟時啟動 nixd
	vim.api.nvim_create_autocmd("FileType", {
		pattern = base_cfg.filetypes,
		callback = function(ev)
			if #vim.lsp.get_clients({ name = base_cfg.name, bufnr = ev.buf }) > 0 then
				return
			end

			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local uv = vim.uv or vim.loop
			local root = util.root_pattern("flake.nix", "default.nix", "shell.nix", ".git")(fname) or uv.cwd()

			-- 判斷是否在系統配置目錄內，若在配置倉庫則鎖定當前 flake，否則指向全域配置路徑
			local is_in_repo = root == nixos_config_dir or root:find(nixos_config_dir, 1, true)
			local flake_expr = is_in_repo and '("git+file://" + toString ./.)' or ('"' .. nixos_config_dir .. '"')

			local dynamic_settings = {
				nixd = {
					nixpkgs = {
						expr = "import <nixpkgs> { }",
					},
					formatting = {
						command = { "nixfmt" },
					},
					options = {
						nixos = {
							expr = '(builtins.getFlake '
								.. flake_expr
								.. ').nixosConfigurations."'
								.. profile
								.. '".options',
						},
						home_manager = {
							expr = 'let flake = builtins.getFlake '
								.. flake_expr
								.. '; in (import (flake.inputs.home-manager.outPath + "/modules") { pkgs = flake.nixosConfigurations."'
								.. profile
								.. '".pkgs; lib = flake.inputs.nixpkgs.lib; configuration = { home.stateVersion = "26.05"; home.username = "wmt"; home.homeDirectory = "/home/wmt"; }; check = false; }).options',
						},
					},
				},
			}

			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
				settings = dynamic_settings,
			}))
		end,
	})
end
