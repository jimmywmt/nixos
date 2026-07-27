-- nvim-jdtls 是一個專為 Java 開發者設計的 LSP 客戶端，它提供了許多 Java 開發所需的功能，例如代碼導航、自動補全、重構等。
-- 熱鍵設定：
-- - <localleader>rn: 重命名
-- - <localleader>xa: 代碼操作
-- - gd: 跳轉到定義
-- - gh: Hover 說明
-- - gD: 跳轉到聲明
-- - gi: 跳轉到實現
-- - gr: 查找引用
-- - go: 打開診斷資訊
-- - g[: 上一個診斷
-- - g]: 下一個診斷

return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	config = function()
		local home = vim.loop.os_homedir()

		-- [1] 動態探測 NixOS 系統安裝的 JDTLS 核心與 config_linux
		local function find_jdtls()
			local jdtls_bin = vim.fn.resolve(vim.fn.exepath("jdtls"))
			if jdtls_bin == "" then
				jdtls_bin = vim.fn.resolve(vim.fn.exepath("jdt-language-server"))
			end
			if jdtls_bin == "" then
				return nil, nil
			end

			local pkg_root = vim.fn.fnamemodify(jdtls_bin, ":h:h")
			local candidates = {
				pkg_root .. "/share/java/jdtls",
				pkg_root .. "/share/jdtls",
				pkg_root,
			}

			for _, base in ipairs(candidates) do
				local launcher = vim.fn.glob(base .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)[1]
				local config_linux = base .. "/config_linux"
				if launcher and vim.fn.isdirectory(config_linux) == 1 then
					return launcher, config_linux -- 💡 只精準回傳需要的兩個元素
				end
			end

			return nil, nil
		end

		local launcher, config_linux = find_jdtls()
		if not launcher then
			vim.notify("[nvim-jdtls] 找不到 JDTLS 核心 JAR 或 config_linux", vim.log.levels.ERROR)
			return
		end

		-- [2] 動態載入 NixOS 提供的 Java Debug 與 Test Bundles
		local bundles = {}

		-- Debug Adapter (com.microsoft.java.debug.plugin-*.jar)
		local debug_jars = vim.fn.glob(
			"/nix/store/*java-debug*/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar",
			true,
			true
		)
		for _, jar in ipairs(debug_jars) do
			table.insert(bundles, jar)
		end

		-- Test Runner (*.jar)
		local test_jars = vim.fn.glob(
			"/nix/store/*java-test*/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar",
			true,
			true
		)
		for _, jar in ipairs(test_jars) do
			table.insert(bundles, jar)
		end

		-- [3] 自動獲取系統 JAVA_HOME
		local function get_java_home()
			local env_java = os.getenv("JAVA_HOME")
			if env_java and vim.fn.isdirectory(env_java) == 1 then
				return env_java
			end
			local java_bin = vim.fn.resolve(vim.fn.exepath("java"))
			if java_bin ~= "" then
				return vim.fn.fnamemodify(java_bin, ":h:h")
			end
			return nil
		end

		local JAVA_HOME = get_java_home()
		if not JAVA_HOME then
			vim.notify("[nvim-jdtls] 找不到有效的 JAVA_HOME", vim.log.levels.ERROR)
			return
		end

		-- 設定獨立的 Workspace 目錄
		local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
		local workspace_dir = home .. "/.jdtls-workspaces/" .. project_name

		-- [4] 設定 Capabilities (整合 Blink)
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
		extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

		-- [5] 啟動引數陣列
		local cmd = {
			JAVA_HOME .. "/bin/java",
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xms1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-jar",
			launcher,
			"-configuration",
			config_linux,
			"-data",
			workspace_dir,
		}

		local config = {
			cmd = cmd,
			root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
			capabilities = capabilities,

			settings = {
				java = {
					eclipse = { downloadSources = true },
					configuration = {
						updateBuildConfiguration = "interactive",
					},
					maven = { downloadSources = true },
					implementationsCodeLens = { enabled = true },
					referencesCodeLens = { enabled = true },
					references = { includeDecompiledSources = true },
					signatureHelp = { enabled = true },
					format = { enabled = false },
				},
			},

			init_options = {
				bundles = bundles,
				extendedClientCapabilities = extendedClientCapabilities,
			},

			on_attach = function(client, bufnr)
				-- 停用 JDTLS 內建格式化 (改用外部格式化器如 google-java-format)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false

				local opts = { buffer = bufnr, silent = true, noremap = true }

				-- 快速鍵設定 (Snacks Picker & 原生 LSP)
				vim.keymap.set("n", "<localleader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<localleader>xa", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)

				vim.keymap.set("n", "gd", function()
					Snacks.picker.lsp_definitions()
				end, opts)
				vim.keymap.set("n", "gr", function()
					Snacks.picker.lsp_references()
				end, opts)
				vim.keymap.set("n", "gi", function()
					Snacks.picker.lsp_implementations()
				end, opts)
				vim.keymap.set("n", "go", function()
					Snacks.picker.diagnostics()
				end, opts)
				vim.keymap.set("n", "gl", function()
					Snacks.picker.lsp_symbols()
				end, opts)
				vim.keymap.set("n", "gs", function()
					Snacks.picker.lsp_workspace_symbols()
				end, opts)

				-- Java 自動匯入套件 (Organize Imports)
				vim.keymap.set("n", "<localleader>jo", function()
					require("jdtls").organize_imports()
				end, opts)
			end,
		}

		require("jdtls").start_or_attach(config)
	end,
}
