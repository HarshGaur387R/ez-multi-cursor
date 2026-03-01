-- ez-multi-cursor: Main entry point
local M = {}

-- Lazy module imports - will be loaded on setup
local Config
local CursorsManager
local Rendering
local Movement
local TextOperations

-- Expose cursors for module access
M.enabled = false

--- Configure the plugin
---@param opts table
function M.setup(opts)
	-- Lazy load modules on setup
	if not Config then
		Config = require("ez-multi-cursor.config")
		CursorsManager = require("ez-multi-cursor.cursors_manager")
		Rendering = require("ez-multi-cursor.rendering")
		Movement = require("ez-multi-cursor.movement")
		TextOperations = require("ez-multi-cursor.text_operations")

		-- Expose cursors for module access
		M.cursors = CursorsManager.cursors
		M.namespace = Rendering.namespace
	end

	-- Setup configuration
	Config.setup(opts)

	-- Setup highlight colors
	Rendering.setup_highlights()

	-- Setup keymaps
	vim.keymap.set('n', '<C-d>', function()
		CursorsManager.add_or_remove_cursor()
	end, { desc = "Adds a psuedo cursor at current cursor" })

	vim.keymap.set('n', '<Esc>', function()
		local buf = vim.api.nvim_get_current_buf()
		Rendering.remove_all_highlights(buf)
		CursorsManager.clear_all_cursors()
		return "<Esc>"
	end, { expr = true })

	vim.keymap.set("n", "<A-Right>", function()
		vim.schedule(function()
			Movement.set_x_cordinate(1)
		end)
		return ""
	end, { desc = "Move to right" })

	vim.keymap.set("n", "<A-Left>", function()
		vim.schedule(function()
			Movement.set_x_cordinate(-1)
		end)
		return ""
	end, { desc = "Move to left" })

	vim.keymap.set("n", "<A-Up>", function()
		vim.schedule(function()
			Movement.set_y_cordinate(CursorsManager.cursors, -1)
		end)
		return ""
	end, { desc = "Move to up" })

	vim.keymap.set("n", "<A-Down>", function()
		vim.schedule(function()
			Movement.set_y_cordinate(CursorsManager.cursors, 1)
		end)
		return ""
	end, { desc = "Move to down" })

	-- Setup autocmds
	vim.api.nvim_create_autocmd("ModeChanged", {
		pattern = "*:i", -- match any mode -> insert mode
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			Rendering.remove_all_highlights(buf)
			CursorsManager.clear_all_cursors()
		end,
	})

	-- Setup user commands
	vim.api.nvim_create_user_command(
		'InsertText',
		function(op)
			TextOperations.insert_text(CursorsManager.cursors, op.args)
		end,
		{
			nargs = 1, -- Require exactly one argument
			desc = "Insert provided text at cursors"
		}
	)
end

return M
