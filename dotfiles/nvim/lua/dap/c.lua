-- lua/dap/c.lua
-- C / C++ DAP 配置 (LLDB / LLDB-DAP)

-- 動態探測系統中的 LLDB DAP 執行檔 (優先序: lldb-dap -> lldb-vscode -> lldb)
local function get_lldb_executable()
	local binaries = { "lldb-dap", "lldb-vscode", "lldb" }
	for _, bin in ipairs(binaries) do
		local path = vim.fn.exepath(bin)
		if path ~= "" then
			return path
		end
	end
	return "lldb-dap" -- Fallback
end

local c_config = {
	{
		type = "lldb",
		request = "launch",
		name = "Launch C/C++ Program",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
		runInTerminal = false,
	},
}

return {
	-- 💡 必須是 Table，Key 為 adapter 名稱 ("lldb")
	adapters = {
		lldb = function(cb, config)
			if config.request == "attach" then
				local port = (config.connect or config).port
				local host = (config.connect or config).host or "127.0.0.1"
				cb({
					type = "server",
					port = assert(port, "`connect.port` is required for a C `attach` configuration"),
					host = host,
				})
			else
				cb({
					type = "executable",
					command = get_lldb_executable(), -- 💡 動態抓取 Nix Store 內建的 lldb
					name = "lldb",
				})
			end
		end,
	},

	-- 💡 必須以語言為 Key ("c", "cpp")
	configurations = {
		c = c_config,
		cpp = c_config,
	},
}
