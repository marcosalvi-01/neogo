-- lua/neogo/config.lua
-- Manages plugin configuration and default options.

local config = {}

---@class GoModifyTagsConfig
---@field cmd string               Command to run gomodifytags.
---@field install_cmd string       Command to install gomodifytags if missing.
---@field popup_input boolean      If true, prompt the user for extra arguments.
---@field add_options string|nil   Comma separated key=option pairs, e.g. "json=omitempty,hcl=squash".
---@field add_tags string|nil      Tags to add as a comma separated list. Keys can include static values, e.g. "json:foo,xml". 
---@field all boolean              If true, process all structs.
---@field clear_options boolean    If true, clear all tag options.
---@field clear_tags boolean       If true, clear all tags.
---@field field string|nil         Field name to be processed.
---@field file string|nil          Filename to be parsed (current buffer's file is used if nil).
---@field format string            Output format. Options: "source" (default) or "json".
---@field line string|nil          Line number or range to process (e.g. "4" or "4,8").
---@field modified boolean         If true, read modified files from standard input.
---@field offset number|nil        Byte offset of the cursor position (automatically determined if nil).
---@field override boolean         If true, override current tags when adding tags.
---@field quiet boolean            If true, suppress output.
---@field remove_options string|nil Comma separated key=option pairs to remove, e.g. "json=omitempty,hcl=squash".
---@field remove_tags string|nil   Tags to remove.
---@field skip_unexported boolean  If true, skip unexported fields.
---@field sort boolean             If true, sort tags by key in increasing order.
---@field struct string|nil        Struct name to be processed.
---@field template string|nil      Template for formatting the tag's value (e.g. "column:{field}").
---@field transform string         Transformation rule to apply to tags. Options: "snakecase" (default), "camelcase", "lispcase", "pascalcase", "titlecase", "keep".
---@field write boolean            If true, write the modified content back to the source file.
---@field extra_args string|nil    Additional command-line arguments.

---@class ToolsOptions
---@field gomodifytags GoModifyTagsConfig
---@field gotests table          Configuration for gotests.
---@field iferr table            Configuration for iferr.
---@field impl table             Configuration for impl.
---@field fillstruct table       Configuration for fillstruct.
---@field fillswitch table       Configuration for fillswitch.
---@field goenum table           Configuration for goenum.

-- Default configuration for all integrated Go tools.
config.options = {
---@type ToolsOptions
	tools = {
		gomodifytags = {
			cmd = "gomodifytags",
			install_cmd = "go install github.com/fatih/gomodifytags@latest",
			popup_input = false,
			add_options = nil,
			add_tags = "json",
			all = false,
			clear_options = false,
			clear_tags = false,
			field = nil,
			file = nil,
			format = "source",
			line = nil,
			modified = false,
			offset = nil,
			override = false,
			quiet = false,
			remove_options = nil,
			remove_tags = nil,
			skip_unexported = false,
			sort = true,
			struct = nil,
			template = nil,
			transform = "snakecase",
			write = false,
			extra_args = nil,
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
