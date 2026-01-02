---@class Zepzeper
local M = {}

---@alias Zepzeper.Position "bottom" | "top" | "left" | "right"

---@class Zepzeper.Win
---@field position Zepzeper.Position Window position
---@field size number Height for bottom/top, width for left/right

---@class Zepzeper.Keymaps
---@field compile string|false Keymap to open compile prompt
---@field recompile string|false Keymap to recompile last command
---@field toggle string|false Keymap to toggle buffer visibility
---@field next_error string|false Keymap to jump to next error
---@field prev_error string|false Keymap to jump to previous error

---@class Zepzeper.BufferKeymaps
---@field quit string|false Close compile buffer
---@field recompile string|false Recompile with last command
---@field run_header string|false Run edited command from header line
---@field kill string|false Kill running compilation
---@field goto_error string|false Jump to error under cursor
---@field next_error string|false Next error in buffer
---@field prev_error string|false Previous error in buffer

---@class Zepzeper.Config
---@field compile_command string Default compile command
---@field save_before_compile boolean Save files before compiling
---@field auto_scroll boolean Auto-scroll to bottom on new output
---@field win Zepzeper.Win Window configuration
---@field keymaps Zepzeper.Keymaps Global keymaps
---@field buffer_keymaps Zepzeper.BufferKeymaps Buffer-local keymaps

---@type Zepzeper.Config
local defaults = {
    compile_command = "make -k",
    save_before_compile = true,
    auto_scroll = true,

    ---@type Zepzeper.Win
    win = {
        position = "bottom",
        size = 15,
    },

    ---@type Zepzeper.Keymaps
    keymaps = {
        compile = "<C-z>c",
        recompile = "<C-z>r",
        toggle = "<C-z>t",
        next_error = "<C-z>n",
        prev_error = "<C-z>p",
    },

    ---@type Zepzeper.BufferKeymaps
    buffer_keymaps = {
        quit = "<C-z>q",
        recompile = "<C-z>r",
        run_header = "<C-z>h",
        kill = "<C-z>k",
        goto_error = "<CR>",
        next_error = "<C-z>n",
        prev_error = "<C-z>p",
    },
}

---@type Zepzeper.Config
M.options = {}

--- Setup the plugin configuration
---@param opts? Zepzeper.Config User configuration options
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

--- Get a configuration value by key
---@param key string Configuration key
---@return any value The configuration value
function M.get(key)
    return M.options[key]
end

--- Get window configuration
---@return Zepzeper.Win
function M.win()
    return M.options.win
end

--- Get global keymaps configuration
---@return Zepzeper.Keymaps
function M.keymaps()
    return M.options.keymaps
end

--- Get buffer-local keymaps configuration
---@return Zepzeper.BufferKeymaps
function M.buffer_keymaps()
    return M.options.buffer_keymaps
end

return M
