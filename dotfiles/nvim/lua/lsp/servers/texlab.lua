-- lua/lsp/servers/texlab.lua
-- 新 API：用 vim.lsp.start 啟動 texlab，針對 NixOS (Wayland + Zathura + Tectonic) 優化

return function(common)
	local util = require("lspconfig.util")

	---------------------------------------------------------------------------
	-- 可調參數 (Wayland / Zathura 對齊)
	---------------------------------------------------------------------------
	local pdf_viewer = "zathura"
	local pdf_args = { "--synctex-forward", "%l:1:%f", "%p" }

	-- tectonic 參數：開啟 synctex、保留中間檔供 log 解析
	local tectonic_args = { "%f", "--synctex", "--keep-logs", "--keep-intermediates" }

	-- 啟用自動清理中間檔（可用 :TexlabToggleAutoClean 切換）
	local AUTO_CLEAN = false

	-- 會清掉的中間檔
	local TMP_EXTS = {
		".aux",
		".bbl",
		".bcf",
		".blg",
		".fdb_latexmk",
		".fls",
		".log",
		".out",
		".run.xml",
		".synctex.gz",
		"-blx.bib",
	}

	local FIXED_TMP_FILES = {
		"indent.log",
	}

	---------------------------------------------------------------------------
	-- 小工具
	---------------------------------------------------------------------------
	local function rooter(fname)
		local pat = util.root_pattern("Tectonic.toml", ".latexmkrc", "latexmkrc", ".git")
		return pat(fname) or vim.loop.cwd()
	end

	local function base_noext()
		return vim.fn.expand("%:r")
	end

	local function cleanup_temp_files()
		local base = base_noext()
		local to_rm = {}

		for _, ext in ipairs(TMP_EXTS) do
			table.insert(to_rm, base .. ext)
		end

		for _, file in ipairs(FIXED_TMP_FILES) do
			table.insert(to_rm, file)
		end

		local cmd = { "rm", "-f" }
		vim.list_extend(cmd, to_rm)
		local out = vim.fn.systemlist(cmd)

		if vim.v.shell_error == 0 then
			vim.notify("Cleanup complete.", vim.log.levels.INFO, { title = "LaTeX Cleanup" })
		else
			vim.notify(
				"Cleanup failed:\n" .. table.concat(out, "\n"),
				vim.log.levels.ERROR,
				{ title = "LaTeX Cleanup" }
			)
		end
	end

	-- 在專案根目錄選出最新的 *.log
	local function find_logfile()
		local preferred = base_noext() .. ".log"
		if vim.fn.filereadable(preferred) == 1 then
			return preferred
		end

		local fname = vim.api.nvim_buf_get_name(0)
		local root = rooter(fname)
		local pattern = root .. "/*.log"
		local logs = vim.fn.glob(pattern, false, true)
		if #logs == 0 then
			return nil
		end

		table.sort(logs, function(a, b)
			local sa = vim.loop.fs_stat(a)
			local sb = vim.loop.fs_stat(b)
			local ma = sa and sa.mtime and sa.mtime.sec or 0
			local mb = sb and sb.mtime and sb.mtime.sec or 0
			return ma > mb
		end)
		return logs[1]
	end

	local function show_tectonic_errors()
		local log = find_logfile()
		if not log then
			vim.notify(
				"No .log file found (tried current buffer and project root).",
				vim.log.levels.WARN,
				{ title = "Tectonic Log" }
			)
			return
		end

		local f = io.open(log, "r")
		if not f then
			vim.notify("Cannot open log: " .. log, vim.log.levels.ERROR, { title = "Tectonic Log" })
			return
		end

		local patterns = {
			"^!%s*(.*)",
			"LaTeX Error:%s*(.*)",
			"Package%s+[%w%-%_]+%s+Error:%s*(.*)",
			"^error:%s*(.*)",
			"^fatal:%s*(.*)",
		}

		local lines = {}
		local ctx = {}
		local ctx_keep = 2

		for line in f:lines() do
			table.insert(ctx, line)
			if #ctx > ctx_keep then
				table.remove(ctx, 1)
			end

			local hit = false
			for _, pat in ipairs(patterns) do
				local m = line:match(pat)
				if m then
					for _, c in ipairs(ctx) do
						table.insert(lines, c)
					end
					table.insert(lines, line)
					hit = true
					break
				end
			end

			if hit then
				local pos = f:seek()
				local nextline = f:read("*l")
				if nextline then
					table.insert(lines, nextline)
				end
				if pos then
					f:seek("set", pos)
				end
			end
		end
		f:close()

		if #lines == 0 then
			vim.notify(
				("No obvious errors detected in log: %s"):format(log),
				vim.log.levels.INFO,
				{ title = "Tectonic Log" }
			)
			return
		end

		vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR, { title = "Tectonic Errors" })
	end

	---------------------------------------------------------------------------
	-- 產生 LSP 啟動設定
	---------------------------------------------------------------------------
	local function make_cfg(bufnr)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local root = rooter(fname)
		return {
			name = "texlab",
			cmd = { "texlab" },
			root_dir = root,
			single_file_support = true,
			capabilities = common.capabilities,
			on_attach = function(client, b)
				if common.on_attach then
					common.on_attach(client, b)
				end

				local function tail_log_once()
					if AUTO_CLEAN then
						show_tectonic_errors()
						cleanup_temp_files()
					else
						show_tectonic_errors()
					end
				end

				-- :TexlabBuild
				local function buf_build()
					vim.notify("Compiling (texlab → tectonic)…", vim.log.levels.INFO, { title = "LaTeX Build" })
					local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
					client:request("textDocument/build", params, function(err, result)
						if err then
							return vim.notify(
								"Build error: " .. err.message,
								vim.log.levels.ERROR,
								{ title = "texlab" }
							)
						end
						local status_map = { [0] = "Success", [1] = "Error", [2] = "Failure", [3] = "Cancelled" }
						local status = status_map[result.status] or "Unknown"
						vim.notify("Build " .. status, vim.log.levels.INFO, { title = "texlab" })
						vim.defer_fn(tail_log_once, 150)
					end, b)
				end

				-- :TexlabForward
				local function buf_forward()
					local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
					client:request("textDocument/forwardSearch", params, function(err, result)
						if err then
							return vim.notify(
								"Forward error: " .. err.message,
								vim.log.levels.ERROR,
								{ title = "texlab" }
							)
						end
						local status_map = { [0] = "Success", [1] = "Error", [2] = "Failure", [3] = "Unconfigured" }
						local status = status_map[result.status] or "Unknown"
						vim.notify("Forward " .. status, vim.log.levels.INFO, { title = "texlab" })
					end, b)
				end

				-- buffer-local 指令 / 快捷鍵
				vim.api.nvim_buf_create_user_command(
					b,
					"TexlabBuild",
					buf_build,
					{ desc = "Build current TeX document" }
				)
				vim.api.nvim_buf_create_user_command(
					b,
					"TexlabForward",
					buf_forward,
					{ desc = "Forward search from cursor" }
				)

				vim.keymap.set("n", "<localleader>ll", buf_build, { buffer = b, desc = "LaTeX Build" })
				vim.keymap.set("n", "<localleader>lv", buf_forward, { buffer = b, desc = "LaTeX Forward Search" })
				vim.keymap.set(
					"n",
					"<localleader>le",
					show_tectonic_errors,
					{ buffer = b, desc = "Show Tectonic Errors" }
				)
				vim.keymap.set(
					"n",
					"<localleader>ld",
					cleanup_temp_files,
					{ buffer = b, desc = "Delete LaTeX Temporary Files" }
				)
			end,
			settings = {
				texlab = {
					build = {
						executable = "tectonic",
						args = tectonic_args,
						onSave = false,
						forwardSearchAfter = true,
					},
					forwardSearch = {
						executable = pdf_viewer,
						args = pdf_args,
					},
					diagnosticsDelay = 300,
					bibtex = {
						format = "latex",
					},
				},
			},
			initialization_options = {
				editorInfo = { name = "neovim", version = (vim.version().major .. "." .. vim.version().minor) },
				editorPluginInfo = { name = "nvim-lspconfig", version = "via-new-api" },
			},
		}
	end

	---------------------------------------------------------------------------
	-- 自動在 TeX 檔啟動 texlab
	---------------------------------------------------------------------------
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "tex", "plaintex" },
		callback = function(ev)
			local bufnr = ev.buf
			if #vim.lsp.get_clients({ name = "texlab", bufnr = bufnr }) == 0 then
				vim.lsp.start(make_cfg(bufnr))
			end
		end,
		desc = "Start texlab (new API)",
	})

	---------------------------------------------------------------------------
	-- 額外使用者命令（全域）
	---------------------------------------------------------------------------
	vim.api.nvim_create_user_command(
		"ShowTectonicErrors",
		show_tectonic_errors,
		{ desc = "Show Tectonic LaTeX Errors from log" }
	)
	vim.api.nvim_create_user_command("TexlabShowLog", function()
		local log = find_logfile()
		if not log then
			return vim.notify("No .log file found.", vim.log.levels.WARN, { title = "Tectonic Log" })
		end
		vim.cmd(("tabnew %s"):format(vim.fn.fnameescape(log)))
	end, { desc = "Open latest LaTeX .log (detected)" })
	vim.api.nvim_create_user_command("TexlabClean", cleanup_temp_files, { desc = "Delete LaTeX Temporary Files" })
	vim.api.nvim_create_user_command("TexlabToggleAutoClean", function()
		AUTO_CLEAN = not AUTO_CLEAN
		vim.notify(
			"Auto-clean temporary files: " .. (AUTO_CLEAN and "ON" or "OFF"),
			vim.log.levels.INFO,
			{ title = "LaTeX Cleanup" }
		)
	end, { desc = "Toggle auto clean after build" })
end
