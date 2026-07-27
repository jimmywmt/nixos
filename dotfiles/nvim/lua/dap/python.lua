-- lua/dap/python.lua
-- Python DAP 配置 (debugpy)

-- 動態尋找最合適的 Python 直譯器 (.venv 優先，支援 direnv / nix develop)
local function get_python_path()
	local cwd = (vim.uv or vim.loop).cwd()

	-- 1. 專案根目錄下的 .venv 或 venv
	if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
		return cwd .. "/.venv/bin/python"
	elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
		return cwd .. "/venv/bin/python"
	end

	-- 2. VIRTUAL_ENV 環境變數
	local env_venv = os.getenv("VIRTUAL_ENV")
	if env_venv and vim.fn.executable(env_venv .. "/bin/python") == 1 then
		return env_venv .. "/bin/python"
	end

	-- 3. Fallback: 使用系統 PATH 中的 python3
	local sys_python = vim.fn.exepath("python3")
	if sys_python ~= "" then
		return sys_python
	end

	return "python3"
end

return {
	-- 💡 必須是 Table，Key 為 adapter 名稱 ("python")
	adapters = {
		python = function(cb, config)
			if config.request == "attach" then
				local port = (config.connect or config).port
				local host = (config.connect or config).host or "127.0.0.1"
				cb({
					type = "server",
					port = assert(port, "`connect.port` is required for a python `attach` configuration"),
					host = host,
					options = { source_filetype = "python" },
				})
			else
				cb({
					type = "executable",
					command = get_python_path(), -- 💡 用找到的 Python 啟動 debugpy
					args = { "-m", "debugpy.adapter" },
					options = { source_filetype = "python" },
				})
			end
		end,
	},

	-- 💡 必須以語言為 Key ("python")
	configurations = {
		python = {
			{
				type = "python",
				request = "launch",
				name = "Launch File",
				program = "${file}",
				pythonPath = get_python_path,
				console = "integratedTerminal",
			},
			{
				type = "python",
				request = "launch",
				name = "Launch File with Arguments",
				program = "${file}",
				args = function()
					local args_str = vim.fn.input("CommandLine Arguments: ")
					return vim.split(args_str, " ")
				end,
				pythonPath = get_python_path,
				console = "integratedTerminal",
			},
		},
	},
}
