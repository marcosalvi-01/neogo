-- lua/neogo/commands/fillswitch.lua
-- Generates switch-case branches for enumerated types.

local config = require("neogo.config")
local tools = require("neogo.tools")
local utils = require("neogo.utils")

local fillswitch = {}

--- Generates a switch-case structure.
--- @param opts table Options (e.g., opts.enum for the enum type, opts.default to include a default case).
function fillswitch.generate(opts)
	opts = opts or {}
	local tool_config = config.options.tools.fillswitch
	local args = ""
	if opts.enum then
		args = args .. " " .. opts.enum
	end
	if opts.default then
		args = args .. " --default"
	end
	local output = tools.run(tool_config, args)
	if output and output ~= "" then
		local pos = utils.get_cursor_position()
		utils.insert_output_after_line(output, pos.line)
	end
	vim.notify("fillswitch executed successfully.", vim.log.levels.INFO)
end

return fillswitch
