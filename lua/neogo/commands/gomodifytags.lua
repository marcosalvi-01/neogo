-- lua/neogo/commands/gomodifytags.lua
-- Provides functions to add, modify, or remove struct tags using gomodifytags.

local config = require("neogo.config")
local tools = require("neogo.tools")
local utils = require("neogo.utils")

local gomodifytags = {}

--- Adds struct tags at the cursor position.
--- @param opts table Options table (e.g., opts.field, opts.tag).
function gomodifytags.add(opts)
	opts = opts or {}
	local tool_config = config.options.tools.gomodifytags
	local args = "--add"
	if opts.field and opts.tag then
		args = args .. string.format(" -field %s -tag %s", opts.field, opts.tag)
	end
	local output = tools.run(tool_config, args)
	if output then
		vim.notify("gomodifytags add executed successfully.", vim.log.levels.INFO)
	end
end

--- Modifies struct tags at the cursor position.
--- @param opts table Options table (e.g., opts.field, opts.new_tag).
function gomodifytags.modify(opts)
	opts = opts or {}
	local tool_config = config.options.tools.gomodifytags
	local args = "--modify"
	if opts.field and opts.new_tag then
		args = args .. string.format(" -field %s -new-tag %s", opts.field, opts.new_tag)
	end
	local output = tools.run(tool_config, args)
	if output then
		vim.notify("gomodifytags modify executed successfully.", vim.log.levels.INFO)
	end
end

--- Removes struct tags at the cursor position.
--- @param opts table Options table (e.g., opts.field).
function gomodifytags.remove(opts)
	opts = opts or {}
	local tool_config = config.options.tools.gomodifytags
	local args = "--remove"
	if opts.field then
		args = args .. string.format(" -field %s", opts.field)
	end
	local output = tools.run(tool_config, args)
	if output then
		vim.notify("gomodifytags remove executed successfully.", vim.log.levels.INFO)
	end
end

return gomodifytags
