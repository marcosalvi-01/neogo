-- lua/neogo/utils.lua
-- Shared utilities for buffer manipulation, cursor position and error notifications.

local utils = {}

--- Notifies an error using Neovim's notification system.
--- @param msg string Error message.
function utils.notify_error(msg)
	vim.notify(msg, vim.log.levels.ERROR)
end

--- Gets the current cursor position in the active window.
--- @return {line: number, col: number} Cursor position.
function utils.get_cursor_position()
	local pos = vim.api.nvim_win_get_cursor(0)
	return { line = pos[1], col = pos[2] }
end

--- Retrieves the current visual selection (if any) as a string.
--- @return string The selected text.
function utils.get_visual_selection()
	local mode = vim.api.nvim_get_mode().mode
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		return ""
	end
	local _, start_row, start_col, _ = unpack(vim.fn.getpos("v"))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("."))
	if start_row > end_row then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end
	local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	if #lines == 0 then
		return ""
	end
	lines[#lines] = string.sub(lines[#lines], 1, end_col)
	lines[1] = string.sub(lines[1], start_col)
	return table.concat(lines, "\n")
end

return utils
