-- lua/neogo/commands/goenum.lua
-- Automates generation of enumerated types and helper functions.

local config = require("neogo.config")
local tools = require("neogo.tools")
local utils = require("neogo.utils")

local goenum = {}

--- Generates enumerated types and their helper functions.
--- @param opts table Options (e.g., opts.name for the enum name).
function goenum.generate(opts)
	opts = opts or {}
	local tool_config = config.options.tools.goenum
	local args = ""
	if opts.name then
		args = args .. " -name " .. opts.name
	end
	local output = tools.run(tool_config, args)
	if output and output ~= "" then
		local pos = utils.get_cursor_position()
		utils.insert_output_after_line(output, pos.line)
	end
	vim.notify("goenum generation executed successfully.", vim.log.levels.INFO)
end

return goenum
