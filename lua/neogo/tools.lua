-- lua/neogo/tools.lua
-- Defines tool management functions: checking, installation, and execution.

local vim = vim
local config = require("neogo.config")
local utils = require("neogo.utils")

local tools = {}

--- Checks if a tool is installed by verifying if its command exists.
--- @param tool_name string Name of the tool command.
--- @return boolean True if installed.
function tools.is_installed(tool_name)
	return vim.fn.executable(tool_name) == 1
end

--- Installs a missing tool using the provided installation command.
--- @param tool_name string Name of the tool.
--- @param install_cmd string Command to install the tool.
--- @return boolean True if installed successfully.
function tools.install(tool_name, install_cmd)
	vim.notify("Installing missing tool: " .. tool_name, vim.log.levels.INFO)
	local output = vim.fn.system(install_cmd)
	if vim.v.shell_error ~= 0 then
		utils.notify_error("Failed to install " .. tool_name .. ": " .. output)
		return false
	end
	vim.notify("Successfully installed " .. tool_name, vim.log.levels.INFO)
	return true
end

--- Ensures a tool is installed, and installs it if missing.
--- @param tool_config table Tool configuration.
--- @return boolean True if tool is available.
function tools.ensure(tool_config)
	if not tools.is_installed(tool_config.cmd) then
		return tools.install(tool_config.cmd, tool_config.install_cmd)
	end
	return true
end

--- Executes a tool command with given arguments.
--- @param tool_config table Tool configuration.
--- @param args string Arguments to pass to the tool.
--- @return string|nil Output from the tool on success, nil on failure.
function tools.run(tool_config, args)
	if not tools.ensure(tool_config) then
		return nil
	end
	local cmd = tool_config.cmd .. " " .. args
	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		utils.notify_error("Error executing " .. tool_config.cmd .. ": " .. output)
		return nil
	end
	return output
end

--- Setup function to initialize tools (e.g. pre-check them).
function tools.setup()
	for _, tool_config in pairs(config.options.tools) do
		tools.ensure(tool_config)
	end
end

return tools
