local M = {}

local config = require("zepzeper.config")
local compile = require("zepzeper.compile")
local buffer = require("zepzeper.buffer")
local commands = require("zepzeper.commands")
local keymaps = require("zepzeper.keymaps")

function M.setup(opts)
    config.setup(opts)
    commands.setup()
    keymaps.setup_global()
end

function M.compile(cmd)
    compile.run(cmd)
end

function M.recompile()
    compile.recompile()
end

function M.next_error()
    compile.next_error()
end

function M.prev_error()
    compile.prev_error()
end

function M.goto_error()
    compile.goto_error()
end

function M.kill()
    compile.kill()
end

function M.toggle()
    buffer.toggle()
end

return M
