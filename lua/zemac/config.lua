---@class Zemac
local M = {}

---@alias Zemac.Position "bottom" | "top" | "left" | "right"

---@class Zemac.Win
---@field position Zemac.Position Window position
---@field size number Height for bottom/top, width for left/right

---@class Zemac.Keymaps
---@field compile string|false Keymap to open compile prompt
---@field recompile string|false Keymap to recompile last command
---@field toggle string|false Keymap to toggle buffer visibility
---@field next_error string|false Keymap to jump to next error
---@field prev_error string|false Keymap to jump to previous error

---@class Zemac.BufferKeymaps
---@field quit string|false Close compile buffer
---@field recompile string|false Recompile with last command
---@field run_header string|false Run edited command from header line
---@field kill string|false Kill running compilation
---@field goto_error string|false Jump to error under cursor
---@field next_error string|false Next error in buffer
---@field history_prev string|false Previous error in buffer
---@field history_next string|false Previous error in buffer

---@class Zemac.Config
---@field compile_command string Default compile command
---@field save_before_compile boolean Save files before compiling
---@field auto_scroll boolean Auto-scroll to bottom on new output
---@field win Zemac.Win Window configuration
---@field keymaps Zemac.Keymaps Global keymaps
---@field buffer_keymaps Zemac.BufferKeymaps Buffer-local keymaps

---@type Zemac.Config
local defaults = {
    compile_command = "make -k",
    save_before_compile = true,
    -- auto_scroll = true,

    ---@type Zemac.Win
    win = {
        position = "bottom",
        size = 15,
    },

    ---@type Zemac.Keymaps
    keymaps = {
        compile = "<C-z>c",
        recompile = "<C-z>r",
        toggle = "<C-z>t",
        next_error = "<C-z>j",
        prev_error = "<C-z>k",
    },

    ---@type Zemac.BufferKeymaps
    buffer_keymaps = {
        quit = "<C-z>q",
        recompile = "<C-z>r",
        run_header = "<C-z>h",
        kill = "<C-z>k",
        goto_error = "<C-z>g",
        next_error = "<C-z>j",
        prev_error = "<C-z>k",
        history_prev = "<C-z>n",
        history_next = "<C-z>p",
    },
}

---@type Zemac.Config
M.options = {}

--- Setup the plugin configuration
---@param opts? Zemac.Config User configuration options
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
---@return Zemac.Win
function M.win()
    return M.options.win
end

--- Get global keymaps configuration
---@return Zemac.Keymaps
function M.keymaps()
    return M.options.keymaps
end

--- Get buffer-local keymaps configuration
---@return Zemac.BufferKeymaps
function M.buffer_keymaps()
    return M.options.buffer_keymaps
end

return M
