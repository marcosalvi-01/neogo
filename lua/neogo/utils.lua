-- lua/neogo/utils.lua
-- Shared utilities for buffer manipulation, cursor position and error notifications.

local utils = {}

--- Finds an appropriate insertion point using Treesitter.
--- This function attempts to locate the outer block (e.g. a function, struct, or interface declaration)
--- that encloses the current cursor. If found, it returns the line number (1-indexed) immediately after
--- the block's end. Otherwise, it returns the current cursor line.
--- @return number The line number where new code should be inserted.
function utils.find_insertion_point()
	local ts_utils_ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
	if not ts_utils_ok then
		return utils.get_cursor_position().line
	end

	local node = ts_utils.get_node_at_cursor()
	if not node then
		return utils.get_cursor_position().line
	end

	local target = node
	while target do
		local node_type = target:type()
		if node_type == "block" or node_type == "interface_type" or node_type == "struct_type" then
			break
		elseif node_type == "type_spec" then
			-- If we are on a type_spec, try to find its child that is a struct or interface type.
			for i = 0, target:named_child_count() - 1 do
				local child = target:named_child(i)
				local child_type = child:type()
				if child_type == "struct_type" or child_type == "interface_type" then
					target = child
					break
				end
			end
			break
		end
		target = target:parent()
	end

	if target then
		-- If the target is a struct_type, climb to its parent (usually a type_spec) to get the full declaration.
		if target:type() == "struct_type" then
			local parent = target:parent()
			if parent and parent:type() == "type_spec" then
				target = parent
			end
		end
		local _start_row, _start_col, end_row, _end_col = target:range()
		return end_row + 1 -- Insert after the block's end.
	else
		return utils.get_cursor_position().line
	end
end

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

--- Gets the current file name (absolute path) of the active buffer.
--- @return string The current file name.
function utils.get_current_filename()
	local filename = vim.fn.expand("%:p")
	return filename
end

--- Computes the byte offset at the current cursor position.
--- @return number|nil byte offset, or nil and error message if it fails.
function utils.get_current_byte_offset()
	local pos = vim.api.nvim_win_get_cursor(0)
	local line = pos[1]
	local col = pos[2]
	local line_byte_offset = vim.fn.line2byte(line)
	if line_byte_offset == -1 then
		return nil, "Unable to compute byte offset for line " .. line
	end
	return line_byte_offset + col
end

--- Inserts output text into the current buffer after the current line with proper indentation.
--- @param output string The output text to insert.
--- @param line number The line number (1-indexed) where the cursor is.
function utils.insert_output_after_line(output, line)
	local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
	local indent = current_line:match("^(%s*)") or ""
	local output_lines = vim.split(output, "\n")
	for i, text in ipairs(output_lines) do
		output_lines[i] = indent .. text
	end
	if output_lines[#output_lines] == "" then
		table.remove(output_lines)
	end
	vim.api.nvim_buf_set_lines(0, line, line, false, output_lines)
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
