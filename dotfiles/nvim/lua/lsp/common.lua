-- lua/lsp/common.lua
local M = {}

-- 共用熱鍵（沿用你原本那組）
M.on_attach = function(_, bufnr)
	-- 輔助函式：讓 keymap 設定更簡潔
	local function mapbuf(mode, lhs, rhs, opts)
		opts = opts or {}
		opts.noremap = true
		opts.silent = true
		opts.buffer = bufnr
		vim.keymap.set(mode, lhs, rhs, opts)
	end

	-- 1. 重構與行動 (由 dressing.nvim 接管 UI)
	-- Lspsaga rename -> 原生 rename
	mapbuf("n", "<localleader>rn", vim.lsp.buf.rename, { desc = "Rename" })

	-- Lspsaga code_action -> 原生 code_action
	mapbuf("n", "<localleader>xa", vim.lsp.buf.code_action, { desc = "Code Action" })

	-- 2. 跳轉與查找 (交給 Snacks 或 原生)
	mapbuf("n", "gd", function()
		Snacks.picker.lsp_definitions()
	end, { desc = "Goto Definition" })
	mapbuf("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
	mapbuf("n", "gi", function()
		Snacks.picker.lsp_implementations()
	end, { desc = "Goto Implementation" })
	mapbuf("n", "gr", function()
		Snacks.picker.lsp_references()
	end, { desc = "References" })

	-- 3. 診斷 (Diagnostics)
	mapbuf("n", "go", function()
		Snacks.picker.diagnostics()
	end, { desc = "Workspace Diagnostics" })

	-- Lspsaga diagnostic_jump_prev -> 原生跳轉
	mapbuf("n", "g[", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "Prev Diagnostic" })

	-- Lspsaga diagnostic_jump_next -> 原生跳轉
	mapbuf("n", "g]", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "Next Diagnostic" })

	-- 4. 文件與懸浮 (Hover)
	-- Lspsaga hover_doc -> 原生 hover (現在已經支援 Markdown 渲染)
	mapbuf("n", "gh", vim.lsp.buf.hover, { desc = "Hover Documentation" })

	-- 5. 特殊功能替代方案
	-- 或者直接用原生 definitio
	mapbuf("n", "gpd", vim.lsp.buf.definition, { desc = "Native Definition Jump" })

	-- Lspsaga outline -> 用 Snacks 的 lsp_symbols 取代
	mapbuf("n", "gl", function()
		Snacks.picker.lsp_symbols()
	end, { desc = "Document Symbols (Outline)" })

	-- Lspsaga incoming/outgoing_calls -> Snacks 也有這功能！
	mapbuf("n", "gci", function()
		Snacks.picker.lsp_incoming_calls()
	end, { desc = "Incoming Calls" })
	mapbuf("n", "gco", function()
		Snacks.picker.lsp_outgoing_calls()
	end, { desc = "Outgoing Calls" })
end

-- cmp 能力
M.capabilities = require("blink.cmp").get_lsp_capabilities()

-- 新 API：用 filetype 自動啟動 LSP（完全不碰 lspconfig）
-- opts 需包含：name, cmd, filetypes, root_dir = function(fname) ... end, settings(可選)
function M.autostart(opts)
	local user_on_attach = opts.on_attach

	vim.api.nvim_create_autocmd("FileType", {
		pattern = opts.filetypes,
		callback = function(ev)
			local fname = vim.api.nvim_buf_get_name(ev.buf)

			-- 安全處理 root_dir：判斷它是函數還是字串
			local root
			if type(opts.root_dir) == "function" then
				root = opts.root_dir(fname)
			else
				root = opts.root_dir or vim.loop.cwd()
			end

			-- 避免重複啟動
			local existing = vim.lsp.get_clients({ name = opts.name, bufnr = ev.buf })
			if #existing > 0 then
				return
			end

			-- 呼叫原生 start
			vim.lsp.start({
				name = opts.name,
				cmd = opts.cmd,
				cmd_env = opts.cmd_env, -- 補上這行！讓環境變數能順利穿透
				root_dir = root,
				capabilities = M.capabilities,
				settings = opts.settings,
				-- 整合式的 on_attach，只定義一次
				on_attach = function(client, bufnr)
					if M.on_attach then
						M.on_attach(client, bufnr)
					end
					if user_on_attach then
						user_on_attach(client, bufnr)
					end
				end,
			})
		end,
	})
end

return M
