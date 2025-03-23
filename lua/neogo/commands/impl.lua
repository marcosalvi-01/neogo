-- lua/neogo/commands/impl.lua
-- Auto-generates method stubs for implementing interfaces.

local config = require("neogo.config")
local tools = require("neogo.tools")
local utils = require("neogo.utils")

local impl = {}

--- Generates method stubs for a given interface.
--- @param interface_name string Name of the interface to implement.
--- @param receiver string Receiver variable name.
function impl.generate(interface_name, receiver)
	if not interface_name or not receiver then
		utils.notify_error("Interface name and receiver must be provided for impl.")
		return
	end
	local tool_config = config.options.tools.impl
	local args = string.format("%s %s", receiver, interface_name)
	local output = tools.run(tool_config, args)
	if output and output ~= "" then
		local pos = utils.get_cursor_position()
		utils.insert_output_after_line(output, pos.line)
	end
	vim.notify("impl generation executed successfully.", vim.log.levels.INFO)
end

return impl
