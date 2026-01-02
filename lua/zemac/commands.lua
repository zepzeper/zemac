---@class Zemac.Commands
local M = {}

--- Setup user commands for the plugin
function M.setup()
    local zemac = require("zemac")

    vim.api.nvim_create_user_command("Compile", function(opts)
        zemac.compile(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", complete = "shellcmd", desc = "Run compile command" })

    vim.api.nvim_create_user_command("Recompile", function()
        zemac.recompile()
    end, { desc = "Recompile with last command" })

    vim.api.nvim_create_user_command("NextError", function()
        zemac.next_error()
    end, { desc = "Jump to next error" })

    vim.api.nvim_create_user_command("PrevError", function()
        zemac.prev_error()
    end, { desc = "Jump to previous error" })

    vim.api.nvim_create_user_command("CompileKill", function()
        zemac.kill()
    end, { desc = "Kill compilation" })

    vim.api.nvim_create_user_command("CompileToggle", function()
        zemac.toggle()
    end, { desc = "Toggle compile buffer" })
end

return M
