-- lua/neogo/commands/impl.lua
-- Auto-generates method stubs for implementing interfaces.
--
-- Official usage:
--   impl 'f *File' io.ReadWriteCloser
--   impl 's *Source' golang.org/x/oauth2.TokenSource
--
-- Additional flags:
--   -comments   include interface comments in the generated stubs (default true)
--   -dir        package source directory, useful for vendored code
--   -recvpkg    package name of the receiver

local config = require("neogo.config")
local utils = require("neogo.utils")

local impl = {}

--- Generates method stubs for implementing an interface.
--- The function uses the current cursor position to try to infer the receiver type
--- (by checking if the cursor is inside a struct declaration or on the type's name).
--- If not found, it prompts for a receiver. Then, it prompts for the interface to implement.
--- The given options are merged with the global configuration.
--- @param opts ImplOpts? Options table for customization.
function impl.generate(opts)
	opts = opts or {}
	-- Merge given options with defaults and any global configuration for impl.
	local default_opts = {
		comments = true,
		dir = nil,
		recvpkg = nil,
	}
	local merged_opts = vim.tbl_deep_extend("force", default_opts, config.options.tools.impl, opts)

	-- Attempt to infer the receiver from the current cursor position.
	local current_line = vim.api.nvim_get_current_line()
	local inferred_type = current_line:match("type%s+([%w_]+)%s+struct")
	local recv = nil
	if inferred_type then
		-- Use the first letter of the type as the receiver variable.
		recv = string.lower(inferred_type:sub(1, 1)) .. " *" .. inferred_type
	end

	-- If no receiver was inferred, prompt the user with a default based on the current word under the cursor.
	if not recv or recv == "" then
		local current_word = vim.fn.expand("<cword>")
		local default_recv = ""
		if current_word and current_word ~= "" then
			default_recv = string.lower(current_word:sub(1, 1)) .. " *" .. current_word
		end
		recv = vim.fn.input("Enter receiver (e.g., f *File): ", default_recv)
		if recv == "" then
			utils.notify_error("impl: Receiver not provided.")
			return
		end
	end

	-- Prompt the user for the interface to implement if not provided.
	local iface = merged_opts.iface or vim.fn.input("Enter interface to implement: ")
	if iface == "" then
		utils.notify_error("impl: Interface not provided.")
		return
	end

	-- Build optional flags based on merged options.
	local flags = ""
	if merged_opts.comments == false then
		flags = flags .. " -comments=false"
	end
	if merged_opts.dir and merged_opts.dir ~= "" then
		flags = flags .. string.format(" -dir %s", merged_opts.dir)
	end
	if merged_opts.recvpkg and merged_opts.recvpkg ~= "" then
		flags = flags .. string.format(" -recvpkg %s", merged_opts.recvpkg)
	end

	-- Build the full command.
	local tool_config = config.options.tools.impl
	-- Wrap receiver in single quotes to avoid shell globbing.
	local cmd = string.format("%s%s '%s' %s", tool_config.cmd, flags, recv, iface)

	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		utils.notify_error("impl execution error: " .. output)
		return
	end

	-- Instead of inserting at the cursor, use Treesitter to find a better insertion point.
	local insertion_line = utils.find_insertion_point()
	utils.insert_output_after_line(output, insertion_line)
	vim.notify("impl generation executed successfully.", vim.log.levels.INFO)
end

return impl
