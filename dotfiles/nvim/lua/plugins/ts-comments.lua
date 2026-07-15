-- ts-comments.nvim: 增強 Neovim 原生註解功能的智慧判斷
-- 專門解決 Vue / React / Svelte 等混合語言檔案中，原生 gcc 判斷錯誤的問題
--
-- 功能：
-- 1. 在 <template> 區塊：使用 HTML 註解 -- 2. 在 <script> 區塊：使用 JS/TS 註解 //
-- 3. 在 <style> 區塊：使用 CSS 註解 /* */
--
-- 熱鍵設定 (Neovim 0.10+ 原生)：
-- - gcc: 註解/取消註解當前行
-- - gc: (Visual Mode) 註解選取區域
-- - gc [count] j: 註解下方 N 行
return {
	"folke/ts-comments.nvim",
	opts = {},
	event = "VeryLazy",
	enabled = vim.fn.has("nvim-0.10.0") == 1,
}
