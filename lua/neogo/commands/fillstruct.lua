-- lua/neogo/commands/fillstruct.lua
-- Auto-fills struct literals with default or placeholder values.

local config = require("neogo.config")
local tools = require("neogo.tools")
local utils = require("neogo.utils")

local fillstruct = {}

--- Fills a struct literal at the cursor position.
--- @param opts table Options for customization.
function fillstruct.at_cursor(opts)
	opts = opts or {}
	local tool_config = config.options.tools.fillstruct
	local args = ""
	local output = tools.run(tool_config, args)
	if output then
		vim.notify("fillstruct executed successfully.", vim.log.levels.INFO)
	end
end

return fillstruct
