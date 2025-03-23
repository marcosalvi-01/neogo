-- lua/neogo/commands/goenum.lua
-- Automates generation of enumerated types and helper functions using the go-enum tool.
-- This function reads the current file and cursor position (ensuring the cursor is on a valid enum declaration),
-- then runs go-enum with the --file flag. We assume that go-enum writes the enum definition into a new file
-- with a _enum.go suffix in the same directory as the original file.
-- The new file is then opened in a new buffer.
local config = require("neogo.config")
local utils = require("neogo.utils")

local goenum = {}

--- Generates enum code from the type declaration at the cursor position.
--- It uses the current file (retrieved via utils.get_current_filename) with the --file flag.
--- Assumes that go-enum creates a new file with a "_enum.go" suffix in the same directory.
--- The new file is then opened in a new buffer.
--- @param opts table Optional options table to pass extra flags to go-enum.
function goenum.generate(opts)
	opts = opts or {}
	local tool_config = config.options.tools.goenum

	-- Get the current file name.
	local filename = utils.get_current_filename()
	if filename == "" then
		utils.notify_error("goenum: Unable to determine file name.")
		return
	end

	-- Check that the current line likely contains an enum declaration.
	local current_line = vim.api.nvim_get_current_line()
	if not current_line:find("ENUM%(") then
		utils.notify_error("goenum: No enum declaration found at the cursor line.")
		return
	end

	-- Build the command arguments. Always pass the current file via the --file flag.
	local args = string.format("--file %s", vim.fn.shellescape(filename))
	if opts.extra then
		args = args .. " " .. opts.extra
	end

	-- Execute the go-enum command.
	local cmd = tool_config.cmd .. " " .. args
	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		utils.notify_error("goenum execution error: " .. output)
		return
	end

	-- Determine the expected new file name: same directory as original, with a _enum.go suffix.
	local dir = vim.fn.fnamemodify(filename, ":h")
	local base = vim.fn.fnamemodify(filename, ":t:r")
	local new_file = string.format("%s/%s_enum.go", dir, base)

	-- Check if the new file exists.
	local stat = vim.loop.fs_stat(new_file)
	if not stat then
		utils.notify_error("goenum: Expected generated file not found: " .. new_file)
		return
	end

	-- Open the new file in a new buffer.
	vim.cmd("edit " .. vim.fn.fnameescape(new_file))
	vim.notify("goenum generated file: " .. new_file, vim.log.levels.INFO)
end

return goenum
