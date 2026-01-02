---@class Zepzeper.Main
---@field setup fun(opts?: Zepzeper.Config) Setup the plugin
---@field compile fun(cmd?: string) Run a compile command
---@field recompile fun() Recompile with last command
---@field next_error fun() Jump to next error
---@field prev_error fun() Jump to previous error
---@field goto_error fun() Jump to error under cursor
---@field kill fun() Kill running compilation
---@field toggle fun() Toggle compile buffer visibility
---@field history_prev fun() Navigate to previous command in history
---@field history_next fun() Navigate to next command in history
local M = {}

local config = require("zepzeper.config")
local compile = require("zepzeper.compile")
local buffer = require("zepzeper.buffer")
local commands = require("zepzeper.commands")
local keymaps = require("zepzeper.keymaps")

--- Setup the plugin with user configuration
---@param opts? Zepzeper.Config User configuration options
function M.setup(opts)
    config.setup(opts)
    commands.setup()
    keymaps.setup_global()
end

--- Run a compile command
---@param cmd? string Command to run (prompts if nil in some contexts)
function M.compile(cmd)
    compile.run(cmd)
end

--- Recompile using the last command
function M.recompile()
    compile.recompile()
end

--- Jump to the next error
function M.next_error()
    compile.next_error()
end

--- Jump to the previous error
function M.prev_error()
    compile.prev_error()
end

--- Jump to error under cursor
function M.goto_error()
    compile.goto_error()
end

--- Kill the running compilation
function M.kill()
    compile.kill()
end

--- Toggle the compile buffer visibility
function M.toggle()
    buffer.toggle()
end

--- Navigate to previous command in history
function M.history_prev()
    compile.history_prev()
end

--- Navigate to next command in history
function M.history_next()
    compile.history_next()
end

return M
