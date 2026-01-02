local M = {}

local config = require("zepzeper.config")

--- Set a keymap if the key is not false/nil
---@param mode string
---@param lhs string|false
---@param rhs function|string
---@param opts table
local function map_if_set(mode, lhs, rhs, opts)
    if lhs and lhs ~= false then
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

--- Setup buffer-local keymaps for the compile window
---@param bufnr number
function M.setup_buffer(bufnr)
    local keys = config.get("buffer_keymaps") or {}
    local opts = { buffer = bufnr, silent = true, nowait = true }

    -- Quit/close buffer
    map_if_set("n", keys.quit, function()
        require("zepzeper.buffer").toggle()
    end, vim.tbl_extend("force", opts, { desc = "Close compile buffer" }))

    -- Recompile with last command
    map_if_set("n", keys.recompile, function()
        require("zepzeper").recompile()
    end, vim.tbl_extend("force", opts, { desc = "Recompile" }))

    -- Kill running job
    map_if_set("n", keys.kill, function()
        require("zepzeper").kill()
    end, vim.tbl_extend("force", opts, { desc = "Kill compilation" }))

    -- Enter: on line 1 = rerun edited command, otherwise jump to error
    map_if_set("n", keys.goto_error, function()
        local line_num = vim.api.nvim_win_get_cursor(0)[1]
        if line_num == 1 then
            -- Get command from line 1 and run it
            local cmd = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
            require("zepzeper").compile(cmd)
        else
            require("zepzeper").goto_error()
        end
    end, vim.tbl_extend(
        "force",
        opts,
        { desc = "Go to error / run command" }
    ))

    -- Next error
    map_if_set("n", keys.next_error, function()
        require("zepzeper").next_error()
    end, vim.tbl_extend("force", opts, { desc = "Next error" }))

    -- Previous error
    map_if_set("n", keys.prev_error, function()
        require("zepzeper").prev_error()
    end, vim.tbl_extend("force", opts, { desc = "Previous error" }))
end

--- Setup global keymaps
function M.setup_global()
    local keys = config.get("keymaps") or {}
    local opts = { silent = true }

    -- Compile (like M-x compile) - prompts for command
    map_if_set("n", keys.compile, function()
        local compile = require("zepzeper.compile")
        local default_cmd = compile.last_command
            or config.get("compile_command")
        vim.ui.input(
            { prompt = "Compile: ", default = default_cmd },
            function(cmd)
                if cmd then
                    require("zepzeper").compile(cmd)
                end
            end
        )
    end, vim.tbl_extend("force", opts, { desc = "Compile" }))

    -- Recompile (like M-x recompile) - runs last command immediately
    map_if_set("n", keys.recompile, function()
        require("zepzeper").recompile()
    end, vim.tbl_extend("force", opts, { desc = "Recompile" }))

    -- Toggle compile buffer visibility
    map_if_set("n", keys.toggle, function()
        require("zepzeper").toggle()
    end, vim.tbl_extend("force", opts, { desc = "Toggle compile buffer" }))

    -- Global next/prev error (like Emacs M-g M-n / M-g M-p)
    map_if_set("n", keys.next_error, function()
        require("zepzeper").next_error()
    end, vim.tbl_extend("force", opts, { desc = "Next compile error" }))

    map_if_set("n", keys.prev_error, function()
        require("zepzeper").prev_error()
    end, vim.tbl_extend("force", opts, { desc = "Previous compile error" }))
end

return M
