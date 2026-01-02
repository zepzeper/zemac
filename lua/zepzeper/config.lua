local M = {}

local defaults = {
    compile_command = "make -k",
    auto_scroll = true,
    auto_close_on_success = false,
    auto_close_delay = 2000,
    buffer_height = 15,
    buffer_position = "bottom",
    save_before_compile = true,

    -- Global keymaps (set to false to disable)
    -- Emacs-inspired keybindings
    keymaps = {
        compile = "<C-k>", -- M-x compile in Emacs
        recompile = "<C-r>r", -- M-x recompile in Emacs
        next_error = "]e", -- M-g M-n in Emacs
        prev_error = "[e", -- M-g M-p in Emacs
    },

    -- Buffer-local keymaps for compile window
    -- Emacs compile-mode inspired
    buffer_keymaps = {
        quit = "q", -- Close compile buffer
        recompile = "g", -- g for "go again" / recompile
        kill = "K", -- Kill running compilation
        goto_error = "<CR>", -- Jump to error under cursor
        next_error = "n", -- Next error (M-n in Emacs)
        prev_error = "p", -- Previous error (M-p in Emacs)
    },
}

M.options = {}

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

function M.get(key)
    return M.options[key]
end

return M
