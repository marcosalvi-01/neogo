-- lua/neogo/commands/gotests.lua
-- Implements functions to generate test stubs for Go functions and methods.

local config = require("neogo.config")
local tools = require("neogo.tools")
local utils = require("neogo.utils")

local gotests = {}

--- Generates tests for the function under the cursor.
--- @param opts table Options table (e.g., opts.func for specifying function name).
function gotests.generate_for_function(opts)
	opts = opts or {}
	local tool_config = config.options.tools.gotests
	local args = "-only " .. (opts.func or "current")
	local output = tools.run(tool_config, args)
	if output and output ~= "" then
		local pos = utils.get_cursor_position()
		utils.insert_output_after_line(output, pos.line)
	end
	vim.notify("gotests generation executed successfully.", vim.log.levels.INFO)
end

--- Generates table-driven tests.
--- @param opts table Options for table-driven test generation.
function gotests.generate_table_tests(opts)
	opts = opts or {}
	local tool_config = config.options.tools.gotests
	local args = "-table"
	local output = tools.run(tool_config, args)
	if output and output ~= "" then
		local pos = utils.get_cursor_position()
		utils.insert_output_after_line(output, pos.line)
	end
	vim.notify("gotests table-driven generation executed successfully.", vim.log.levels.INFO)
end

return gotests
