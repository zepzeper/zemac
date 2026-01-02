---@class Zemac.Buffer
---@field bufnr number|nil Buffer number for compile output
---@field winnr number|nil Window number for compile output
---@field job_id number|nil Current job ID
---@field HEADER_LINES number Number of header lines (command + separator)
local M = {}

---@type number|nil
M.bufnr = nil
---@type number|nil
M.winnr = nil
---@type number|nil
M.job_id = nil
-- Command + divider line
---@type number
M.HEADER_LINES = 2
---@type number|nil
M.source_winnr = nil

--- Setup the buffer header with command and separator
---@param command string The compile command to display
function M.setup_header(command)
    M.create()
    local separator = string.rep("─", 80)
    vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, {
        command,
        separator,
    })
end

--- Create the compile buffer if it doesn't exist
---@return number bufnr The buffer number
function M.create()
    if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
        return M.bufnr
    end

    -- Check if a buffer with our name already exists (e.g., after plugin reload)
    local existing = vim.fn.bufnr("zemac-output")
    if existing ~= -1 and vim.api.nvim_buf_is_valid(existing) then
        M.bufnr = existing
        return M.bufnr
    end

    M.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(M.bufnr, "zemac-output")
    vim.bo[M.bufnr].buftype = "nofile"
    vim.bo[M.bufnr].bufhidden = "hide"
    vim.bo[M.bufnr].swapfile = false
    vim.bo[M.bufnr].filetype = "compile"
    -- Setup buffer-local keymaps
    require("zemac.keymaps").setup_buffer(M.bufnr)

    return M.bufnr
end

--- Open the compile buffer window
function M.open()
    local config = require("zemac.config")
    local win = config.win()
    local bufnr = M.create()
    M.source_winnr = vim.api.nvim_get_current_win()

    if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
        vim.api.nvim_set_current_win(M.winnr)
        return
    end

    -- Determine split command based on position
    local split_cmd
    if win.position == "bottom" then
        split_cmd = "botright split"
    elseif win.position == "top" then
        split_cmd = "topleft split"
    elseif win.position == "left" then
        split_cmd = "topleft vsplit"
    elseif win.position == "right" then
        split_cmd = "botright vsplit"
    else
        split_cmd = "botright split" -- fallback
    end

    vim.cmd(split_cmd)
    M.winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(M.winnr, bufnr)

    -- Set window size
    if win.position == "bottom" or win.position == "top" then
        vim.api.nvim_win_set_height(M.winnr, win.size)
    else
        vim.api.nvim_win_set_width(M.winnr, win.size)
    end
end

--- Close and delete the compile buffer
function M.close()
    local bufnr = M.bufnr

    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end

--- Clear the buffer content (preserving header)
function M.clear()
    if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
        -- Only clear lines after header
        local line_count = vim.api.nvim_buf_line_count(M.bufnr)
        if line_count > M.HEADER_LINES then
            vim.api.nvim_buf_set_lines(M.bufnr, M.HEADER_LINES, -1, false, {})
        end
    end
end

--- Append lines to the buffer after the header
---@param lines string[] Lines to append
function M.append(lines)
    local config = require("zemac.config")
    if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
        -- Append after header, -1 means end of buffer
        local line_count = vim.api.nvim_buf_line_count(M.bufnr)
        vim.api.nvim_buf_set_lines(
            M.bufnr,
            line_count,
            line_count,
            false,
            lines
        )
    end

    -- -- Auto-scroll while keeping header visible
    -- if config.get("auto_scroll") and M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
    --     vim.api.nvim_win_call(M.winnr, function()
    --         -- Scroll to bottom
    --         vim.cmd("normal! G")
    --         -- Force header to stay visible at top
    --         vim.fn.winrestview({ topline = 1 })
    --     end)
    -- end
end

--- Toggle the compile buffer window visibility
function M.toggle()
    if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
        vim.api.nvim_win_hide(M.winnr)
        M.winnr = nil
    else
        M.open()
    end
end

--- Set the current job ID
---@param id number|nil Job ID or nil to clear
function M.set_job(id)
    M.job_id = id
end

--- Get the current job ID
---@return number|nil job_id Current job ID
function M.get_job()
    return M.job_id
end

--- Check if a job is currently running
---@return boolean is_running True if a job is running
function M.is_running()
    return M.job_id ~= nil
end

return M
