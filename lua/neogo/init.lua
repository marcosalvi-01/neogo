-- lua/neogo/init.lua
-- Main entry point for neogo.nvim, exposing the API.

local config = require("neogo.config")
local tools = require("neogo.tools")

local M = {}

--- Setup function for neogo.nvim.
--- @param user_config table? User configuration table.
function M.setup(user_config)
	config.setup(user_config or {})
	tools.setup()
end

-- Export commands from submodules.
M.gomodifytags = require("neogo.commands.gomodifytags")
M.iferr = require("neogo.commands.iferr")
M.impl = require("neogo.commands.impl")
M.fixplurals = require("neogo.commands.fixplurals")
M.goenum = require("neogo.commands.goenum")

M.version = "0.1.0"

return M
