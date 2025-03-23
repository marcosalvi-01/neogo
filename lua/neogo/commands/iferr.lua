-- lua/neogo/commands/iferr.lua
-- Inserts boilerplate error-checking snippets using iferr.

local config = require("neogo.config")
local utils = require("neogo.utils")

--- @class IferrOpts
--- @field message string|nil Optional custom error message.

local iferr = {}

--- Inserts an error checking snippet at the cursor position.
--- Automatically calculates the byte offset from the current cursor position,
--- retrieves the current file name, and uses the provided custom message if available.
--- The command is constructed as:
---   iferr -pos {bytes} [-message {custom message}] < {filename}
--- and its output is inserted into the current buffer in a new line after the current line.
--- @param opts IferrOpts? Options table for customization.
function iferr.insert(opts)
	opts = opts or {}
	local tool_config = config.options.tools.iferr

	-- Get current file name.
	local filename = utils.get_current_filename()
	if filename == "" then
		utils.notify_error("iferr: Unable to determine file name.")
		return
	end

	-- Get current cursor position.
	local pos = utils.get_cursor_position()
	local line = pos.line

	-- Compute byte offset from current cursor position.
	local byte_offset, err = utils.get_current_byte_offset()
	if not byte_offset then
		utils.notify_error("iferr: " .. err)
		return
	end

	-- Build the command arguments.
	local args = string.format("-pos %d", byte_offset)
	if opts.message then
		args = args .. string.format(" -message %q", opts.message)
	end

	-- Build and execute the command with input redirection from the file.
	local cmd = string.format("%s %s < %s", tool_config.cmd, args, filename)
	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		utils.notify_error("iferr execution error: " .. output)
		return
	end
	output = output:gsub("\n$", "")

	-- Insert the output after the current line with proper indentation.
	utils.insert_output_after_line(output, line)

	vim.notify("iferr snippet inserted successfully.", vim.log.levels.INFO)
end

return iferr
