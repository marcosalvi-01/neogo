-- lua/neogo/commands/iferr.lua
-- Inserts boilerplate error-checking snippets using iferr.

local config = require("neogo.config")
local utils = require("neogo.utils")

--- @class IferrOpts
--- @field message string|nil Optional custom error message.

local iferr = {}

--- Inserts an error checking snippet at the cursor position.
--- Automatically calculates the byte offset from the current cursor position,
--- gets the current file name, and uses the provided custom message if available.
--- The command is constructed as:
---   iferr -pos {bytes} [-message {custom message}] < {filename}
--- and its output is inserted into the current buffer in a new line after the current line.
--- @param opts IferrOpts? Options table for customization.
function iferr.insert(opts)
	opts = opts or {}
	local tool_config = config.options.tools.iferr

	-- Get current buffer's file name.
	local filename = vim.fn.expand("%:p")
	if filename == "" then
		utils.notify_error("iferr: Unable to determine file name.")
		return
	end

	-- Get current cursor position (line, col with col 0-indexed).
	local pos = vim.api.nvim_win_get_cursor(0)
	local line = pos[1]
	local col = pos[2]

	-- Calculate byte offset of the current cursor position.
	local line_byte_offset = vim.fn.line2byte(line)
	if line_byte_offset == -1 then
		utils.notify_error("iferr: Unable to compute byte offset for line " .. line)
		return
	end
	local byte_offset = line_byte_offset + col

	-- Build the command arguments.
	local args = string.format("-pos %d", byte_offset)
	if opts.message then
		args = args .. string.format(" -message %q", opts.message)
	end

	-- Build the full command with input redirection from the file.
	local cmd = string.format("%s %s < %s", tool_config.cmd, args, filename)

	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		utils.notify_error("iferr execution error: " .. output)
		return
	end

	-- Get the current line's content and determine its indentation.
	local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
	local indent = current_line:match("^(%s*)") or ""

	-- Split output into lines and prepend the indentation.
	local output_lines = vim.split(output, "\n")
	for i, text in ipairs(output_lines) do
		output_lines[i] = indent .. text
	end
	-- Remove the last empty new line
	table.remove(output_lines)

	-- Insert the output on a new line after the current line.
	vim.api.nvim_buf_set_lines(0, line, line, false, output_lines)

	vim.notify("iferr snippet inserted successfully.", vim.log.levels.DEBUG)
end

return iferr
