-- lua/neogo/config.lua
-- Manages plugin configuration and default options.

local config = {}

-- Default configuration for all integrated Go tools.
config.options = {
	tools = {
		gomodifytags = {
			cmd = "gomodifytags",
			install_cmd = "go install github.com/fatih/gomodifytags@latest",
		},
		gotests = {
			cmd = "gotests",
			install_cmd = "go install github.com/cweill/gotests/...@latest",
		},
		iferr = {
			cmd = "iferr",
			install_cmd = "go install github.com/koron/iferr@latest",
		},
		impl = {
			cmd = "impl",
			install_cmd = "go install github.com/josharian/impl@latest",
		},
		fillstruct = {
			cmd = "fillstruct",
			install_cmd = "go install github.com/davidrjonas/fillstruct@latest",
		},
		fillswitch = {
			cmd = "fillswitch",
			install_cmd = "go install github.com/davidrjonas/fillswitch@latest",
		},
		goenum = {
			cmd = "go-enum",
			install_cmd = "go install github.com/abice/go-enum@latest",
		},
	},
}

--- Setup configuration with user provided options.
--- @param user_config table User provided configuration options.
function config.setup(user_config)
	if user_config and user_config.tools then
		for tool, opts in pairs(user_config.tools) do
			if config.options.tools[tool] then
				for key, value in pairs(opts) do
					config.options.tools[tool][key] = value
				end
			end
		end
	end
end

return config
