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

---@class IfErrConfig
---@field cmd string               Command to run iferr.
---@field install_cmd string       Command to install iferr if missing.
---@field message string|nil	   Custom error to use instead of default 'err' e.g. 'fmt.Errorf("error: %w", err)'

--- @class GoenumOpts
--- @field cmd string               Command to run iferr.
--- @field install_cmd string       Command to install iferr if missing.
--- @field show_generated boolean Wether to open the generated file in a new buffer.
--- @field extra string|nil Additional custom flags.
--- @field noprefix boolean Prevents the constants generated from having the enum as a prefix.
--- @field lower boolean Adds lowercase variants of the enum strings for lookup.
--- @field nocase boolean Adds case insensitive parsing (implies lower).
--- @field marshal boolean Adds text marshalling functions.
--- @field sql boolean Adds SQL database scan and value functions.
--- @field sqlint boolean Stores string typed enums as integers in SQL.
--- @field flag boolean Adds golang flag functions.
--- @field prefix string|nil Custom prefix for the generated constants.
--- @field names boolean Generates a 'Names() []string' function.
--- @field values boolean Generates a 'Values() []{{ENUM}}' function.
--- @field nocamel boolean Disables snake_case to CamelCase conversion.
--- @field ptr boolean Adds a pointer method to get a pointer from const values.
--- @field sqlnullint boolean Generates a Null{{ENUM}} type for nullable int values.
--- @field sqlnullstr boolean Generates a Null{{ENUM}} type for nullable string values.
--- @field template string|nil Path to a custom template file.
--- @field alias string|nil Aliases for non-alphanumeric values (e.g., "key:value").
--- @field mustparse boolean Adds a Must version of the Parse function.
--- @field forcelower boolean Forces a camel cased comment to generate lowercased names.
--- @field forceupper boolean Forces a camel cased comment to generate uppercased names.
--- @field nocomments boolean Removes auto-generated comments.
--- @field buildtag string|nil Adds build tags to the generated enum file.

--- @class FixpluralsOpts
--- @field cmd string               Command to run iferr.
--- @field install_cmd string       Command to install iferr if missing.
--- @field packages string|nil Package(s) to run fixplurals on. Defaults to the directory of the current file.

---@class ToolsOptions
---@field gomodifytags GoModifyTagsConfig
---@field gotests table          Configuration for gotests.
---@field iferr IfErrConfig      Configuration for iferr.
---@field impl table             Configuration for impl.
---@field fixplurals FixpluralsOpts
---@field goenum GoenumOpts           Configuration for goenum.

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
			message = nil,
		},
		impl = {
			cmd = "impl",
			install_cmd = "go install github.com/josharian/impl@latest",
		},
		-- TODO: recursive (or not) fillstruct using gopls
		-- TODO: fillswitch (it works only on type switches)
		fixplurals = {
			cmd = "fixplurals",
			install_cmd = "go install github.com/davidrjenni/reftools/cmd/fixplurals@latest",
		},
		goenum = {
			cmd = "go-enum",
			install_cmd = "go install github.com/abice/go-enum@latest",
			show_generated = false,
			extra = nil,
			noprefix = false,
			lower = false,
			nocase = false,
			marshal = false,
			sql = false,
			sqlint = false,
			flag = false,
			prefix = nil,
			names = false,
			values = true,
			nocamel = false,
			ptr = false,
			sqlnullint = false,
			sqlnullstr = false,
			template = nil,
			alias = nil,
			mustparse = false,
			forcelower = false,
			forceupper = false,
			nocomments = false,
			buildtag = nil,
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
