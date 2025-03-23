-- lua/neogo/commands/fixplurals.lua
-- Automates the removal of redundant parameter and result types in Go function signatures using fixplurals.

local config = require("neogo.config")
local tools = require("neogo.tools")

local fixplurals = {}

--- Runs fixplurals on the specified package(s) to remove redundant parameter and result types.
--- It merges the provided options with the global configuration for fixplurals.
--- @param opts FixpluralsOpts? Options for fixplurals.
function fixplurals.run(opts)
	opts = opts or {}
	-- Merge provided options with the global config for fixplurals.
	local tool_config = vim.tbl_deep_extend("force", config.options.tools.fixplurals or {}, opts)

	-- Determine the packages argument: default to the current file's directory if not provided.
	local packages = "."

	-- Build command arguments based on options.
	local args = ""
	args = args .. " " .. packages

	local output = tools.run(tool_config, args)
	if output and output ~= "" then
		vim.notify(output, vim.log.levels.WARN)
	end
	vim.cmd("e")
	vim.notify("fixplurals executed successfully.", vim.log.levels.INFO)
end

return fixplurals
