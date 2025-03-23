-- lua/neogo/commands/gomodifytags.lua
-- Provides a comprehensive interface for gomodifytags with full support for its flags.

local config = require("neogo.config")
local tools = require("neogo.tools")
local utils = require("neogo.utils")

local gomodifytags = {}

--- Build the argument string from the provided options table.
--- @param opts GoModifyTagsConfig Options table containing any of the gomodifytags flags.
--- @return string The concatenated arguments string.
local function build_args(opts)
	local args = {}
	if opts.add_options then
		table.insert(args, string.format("-add-options %q", opts.add_options))
	end
	if opts.add_tags then
		table.insert(args, string.format("-add-tags %q", opts.add_tags))
	end
	if opts.all then
		table.insert(args, "-all")
	end
	if opts.clear_options then
		table.insert(args, "-clear-options")
	end
	if opts.clear_tags then
		table.insert(args, "-clear-tags")
	end
	if opts.field then
		table.insert(args, string.format("-field %s", opts.field))
	end
	if opts.file then
		table.insert(args, string.format("-file %s", opts.file))
	end
	if opts.format then
		table.insert(args, string.format("-format %s", opts.format))
	end
	if opts.line then
		table.insert(args, string.format("-line %s", opts.line))
	end
	if opts.modified then
		table.insert(args, "-modified")
	end
	if opts.offset then
		table.insert(args, string.format("-offset %d", opts.offset))
	end
	if opts.override then
		table.insert(args, "-override")
	end
	if opts.quiet then
		table.insert(args, "-quiet")
	end
	if opts.remove_options then
		table.insert(args, string.format("-remove-options %q", opts.remove_options))
	end
	if opts.remove_tags then
		table.insert(args, string.format("-remove-tags %q", opts.remove_tags))
	end
	if opts.skip_unexported then
		table.insert(args, "-skip-unexported")
	end
	if opts.sort then
		table.insert(args, "-sort")
	end
	if opts.struct then
		table.insert(args, string.format("-struct %s", opts.struct))
	end
	if opts.template then
		table.insert(args, string.format("-template %q", opts.template))
	end
	if opts.transform then
		table.insert(args, string.format("-transform %s", opts.transform))
	end
	if opts.write then
		table.insert(args, "-w")
	end
	if opts.extra_args then
		table.insert(args, opts.extra_args)
	end
	return table.concat(args, " ")
end

--- Executes the gomodifytags command with the provided options.
--- Automatically fills in missing offset and file if not provided.
--- The output is expected to be the full file content, so the whole buffer is updated.
--- Merges the function opts with the default config (with function opts taking priority).
--- @param opts GoModifyTagsConfig? Options table supporting any of the gomodifytags flags.
function gomodifytags.execute(opts)
	opts = opts or {}
	-- Merge default config with opts, giving priority to opts passed in
	opts = vim.tbl_deep_extend("force", config.options.tools.gomodifytags, opts)
	-- Extract the tool configuration (cmd and install_cmd)
	local tool_config = { cmd = opts.cmd, install_cmd = opts.install_cmd }

	-- Automatically determine the byte offset if not provided.
	if not opts.offset then
		local byte_offset, err = utils.get_current_byte_offset()
		if not byte_offset then
			utils.notify_error("gomodifytags: " .. err)
			return
		end
		opts.offset = byte_offset
	end

	-- Automatically determine the file if not provided.
	if not opts.file then
		local filename = utils.get_current_filename()
		if filename == "" then
			utils.notify_error("gomodifytags: Unable to determine file name.")
			return
		end
		opts.file = filename
	end

	local args = build_args(opts)
	local output = tools.run(tool_config, args)
	if output and output ~= "" then
		local lines = vim.split(output, "\n")
		if lines[#lines] == "" then
			table.remove(lines, #lines)
		end
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	end
	vim.notify("gomodifytags command executed successfully.", vim.log.levels.INFO)
end

--- Prompts the user for additional arguments via a popup (if configured)
--- and then executes the gomodifytags command.
--- @param opts table Options table supporting any of the gomodifytags flags.
function gomodifytags.prompt_execute(opts)
	opts = opts or {}
	-- Merge defaults and opts as in execute
	opts = vim.tbl_deep_extend("force", config.options.tools.gomodifytags, opts)
	if opts.popup_input then
		vim.ui.input({ prompt = "Enter additional gomodifytags arguments:" }, function(input)
			if input and input ~= "" then
				opts.extra_args = input
			end
			gomodifytags.execute(opts)
		end)
	else
		gomodifytags.execute(opts)
	end
end

-- Convenience wrappers for common operations.

--- Adds tags using gomodifytags.
--- @param opts GoModifyTagsConfig? Options for adding tags.
function gomodifytags.add(opts)
	opts = opts or {}
	return gomodifytags.prompt_execute(opts)
end

--- Modifies tags using gomodifytags.
--- @param opts GoModifyTagsConfig? Options for modifying tags.
function gomodifytags.modify(opts)
	opts = opts or {}
	return gomodifytags.prompt_execute(opts)
end

--- Removes tags using gomodifytags.
--- @param opts GoModifyTagsConfig? Options for removing tags.
function gomodifytags.remove(opts)
	opts = opts or {}
	return gomodifytags.prompt_execute(opts)
end

-- TODO: implement toggle api

return gomodifytags
