-- lua/neogo/commands/goenum.lua
-- Automates generation of enumerated types and helper functions using the go-enum tool.
-- This function reads the current file and cursor position (ensuring the cursor is on an enum declaration),
-- merges global configuration options with function-provided options,
-- builds the appropriate flags, executes go-enum, and finally opens the generated file in a new buffer.

local config = require("neogo.config")
local utils = require("neogo.utils")

local goenum = {}

--- Merges two option tables giving priority to the second table's values.
--- @param global table Global options.
--- @param opts table Function-specific options.
--- @return table Merged options.
local function merge_options(global, opts)
	return vim.tbl_deep_extend("force", global or {}, opts or {})
end

--- Constructs additional flags for the go-enum command from the merged options.
--- @param opts GoenumOpts The merged options.
--- @return string A string with all additional flags.
local function build_extra_flags(opts)
	local flag_mapping = {
		noprefix = "--noprefix",
		lower = "--lower",
		nocase = "--nocase",
		marshal = "--marshal",
		sql = "--sql",
		sqlint = "--sqlint",
		flag = "--flag",
		names = "--names",
		values = "--values",
		nocamel = "--nocamel",
		ptr = "--ptr",
		sqlnullint = "--sqlnullint",
		sqlnullstr = "--sqlnullstr",
		mustparse = "--mustparse",
		forcelower = "--forcelower",
		forceupper = "--forceupper",
		nocomments = "--nocomments",
	}

	local flags = {}

	for key, flag in pairs(flag_mapping) do
		if opts[key] then
			table.insert(flags, flag)
		end
	end

	-- Options that require formatting with a value.
	if opts.prefix and opts.prefix ~= "" then
		table.insert(flags, string.format("--prefix %s", vim.fn.shellescape(opts.prefix)))
	end
	if opts.template and opts.template ~= "" then
		table.insert(flags, string.format("--template %s", vim.fn.shellescape(opts.template)))
	end
	if opts.alias and opts.alias ~= "" then
		table.insert(flags, string.format("--alias %s", vim.fn.shellescape(opts.alias)))
	end
	if opts.buildtag and opts.buildtag ~= "" then
		table.insert(flags, string.format("--buildtag %s", vim.fn.shellescape(opts.buildtag)))
	end

	-- Allow extra custom flags.
	if opts.extra and opts.extra ~= "" then
		table.insert(flags, opts.extra)
	end

	return table.concat(flags, " ")
end

--- Generates enum code from the type declaration at the cursor position.
--- It uses the current file (retrieved via utils.get_current_filename) with the --file flag.
--- The generated file is assumed to be created with a "_enum.go" suffix in the same directory.
--- The new file is then opened in a new buffer.
--- @param opts GoenumOpts? Optional options table to pass extra flags to go-enum.
function goenum.generate(opts)
	opts = opts or {}

	local tool_config = config.options.tools.goenum
	-- Merge global options (if any) with function-specific ones.
	--- @type GoenumOpts
	local merged_opts = merge_options(tool_config, opts)

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
	local extra_flags = build_extra_flags(merged_opts)
	local args = string.format("--file %s %s", vim.fn.shellescape(filename), extra_flags)

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

	-- Open the new file in a new buffer
	if merged_opts.show_generated then
		vim.cmd("edit " .. vim.fn.fnameescape(new_file))
	end
	vim.notify("goenum generated file: " .. new_file, vim.log.levels.INFO)
end

return goenum
