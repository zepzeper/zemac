local M = {}

M.bufnr = nil
M.winnr = nil
M.job_id = nil

function M.create()
    if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
        return M.bufnr
    end
    M.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(M.bufnr, "zepzeper-output")
    vim.api.nvim_buf_set_option(M.bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(M.bufnr, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(M.bufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(M.bufnr, "filetype", "compile")

    -- Setup buffer-local keymaps
    require("zepzeper.keymaps").setup_buffer(M.bufnr)

    return M.bufnr
end

function M.open()
    local bufnr = M.create()
    if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
        vim.api.nvim_set_current_win(M.winnr)
    else
        vim.cmd("split")
        M.winnr = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(M.winnr, bufnr)
    end
end

function M.close()
    local bufnr = M.bufnr

    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end

function M.clear()
    if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
        vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, {})
    end
end

function M.append(lines)
    if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
        vim.api.nvim_buf_set_lines(M.bufnr, -1, -1, false, lines)
    end
end

function M.toggle()
    if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
        vim.api.nvim_win_hide(M.winnr)
        M.winnr = nil
    else
        M.open()
    end
end

function M.set_job(id)
    M.job_id = id
end

function M.get_job()
    return M.job_id
end

function M.is_running()
    return M.job_id ~= nil
end

return M
