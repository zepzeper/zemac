---@class Zepzeper.Commands
local M = {}

--- Setup user commands for the plugin
function M.setup()
    local zepzeper = require("zepzeper")

    vim.api.nvim_create_user_command("Compile", function(opts)
        zepzeper.compile(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", complete = "shellcmd", desc = "Run compile command" })

    vim.api.nvim_create_user_command("Recompile", function()
        zepzeper.recompile()
    end, { desc = "Recompile with last command" })

    vim.api.nvim_create_user_command("NextError", function()
        zepzeper.next_error()
    end, { desc = "Jump to next error" })

    vim.api.nvim_create_user_command("PrevError", function()
        zepzeper.prev_error()
    end, { desc = "Jump to previous error" })

    vim.api.nvim_create_user_command("CompileKill", function()
        zepzeper.kill()
    end, { desc = "Kill compilation" })

    vim.api.nvim_create_user_command("CompileToggle", function()
        zepzeper.toggle()
    end, { desc = "Toggle compile buffer" })
end

return M
