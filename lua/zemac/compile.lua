---@class Zemac.Compile
---@field last_command string|nil Last executed compile command
---@field errors Zemac.Error[] List of parsed errors
---@field current_error_idx number Current error index for navigation
---@field command_history string[] List of previous commands
---@field history_index number Current position when browsing history (0 = new command)
local M = {}

---@class Zemac.Error
---@field file string File path
---@field lnum number Line number
---@field col number Column number
---@field text string Error message text
---@field type? string Error type (error, warning, etc.)

---@type string|nil
M.last_command = nil
---@type Zemac.Error[]
M.errors = {}
---@type number
M.current_error_idx = 0
---@type string[]
M.command_history = {}
---@type number
M.history_index = 0

--- Run a compile command
---@param cmd string Command to run
function M.run(cmd)
    local config = require("zemac.config")
    local command = cmd or config.get("compile_command")
    M.last_command = command

    -- Save all buffers before compiling
    if config.get("save_before_compile") then
        vim.cmd("silent! wall") -- silent! ignores errors for readonly buffers
    end

    local buffer = require("zemac.buffer")
    buffer.setup_header(command)
    buffer.open()

    local job_id = vim.fn.jobstart(command, {
        cwd = vim.fn.getcwd(),
        on_stdout = function(_, data)
            vim.schedule(function()
                buffer.append(data)
            end)
        end,
        on_stderr = function(_, data)
            vim.schedule(function()
                buffer.append(data)
            end)
        end,
        on_exit = function(_, code)
            vim.schedule(function()
                buffer.set_job(nil) -- Clear job on exit
                if code ~= 0 then
                    buffer.append({ "", "Exited with code: " .. code })
                end

                -- Debug: parse and print errors
                local parser = require("zemac.parser")
                local compiler = parser.detect_compiler(command)
                M.errors = parser.parse_buffer(buffer.bufnr, compiler)
                M.current_error_idx = 0
            end)
        end,
    })

    buffer.set_job(job_id)

    if M.command_history[#M.command_history] ~= command then
        table.insert(M.command_history, command)
    end
    M.history_index = 0 -- Reset to "new command" position
end

--- Recompile using the last command
function M.recompile()
    if M.last_command then
        M.run(M.last_command)
        return
    end

    vim.notify("No previous compile command", vim.log.levels.WARN)
end

--- Jump to the next error in the list
function M.next_error()
    local buffer = require("zemac.buffer")
    if #M.errors == 0 then
        vim.notify("No errors to jump to", vim.log.levels.WARN)
        return
    end

    M.current_error_idx = M.current_error_idx + 1
    if M.current_error_idx > #M.errors then -- wrap around
        M.current_error_idx = 1
    end

    local err = M.errors[M.current_error_idx]
    -- Go to previous window
    if buffer.source_winnr and vim.api.nvim_win_is_valid(buffer.source_winnr) then
        vim.api.nvim_set_current_win(buffer.source_winnr)
    else
        vim.cmd("wincmd p")
    end

    vim.cmd("edit " .. err.file)
    vim.api.nvim_win_set_cursor(0, {err.lnum, (err.col or 1) - 1})
end

--- Jump to the previous error in the list
function M.prev_error()
    local buffer = require("zemac.buffer")
    if #M.errors == 0 then
        vim.notify("No errors to jump to", vim.log.levels.WARN)
        return
    end

    M.current_error_idx = M.current_error_idx - 1
    if M.current_error_idx < 1 then -- wrap around
        M.current_error_idx = #M.errors
    end

    local err = M.errors[M.current_error_idx]
    -- Go to previous window
    if buffer.source_winnr and vim.api.nvim_win_is_valid(buffer.source_winnr) then
        vim.api.nvim_set_current_win(buffer.source_winnr)
    else
        vim.cmd("wincmd p")
    end

    vim.cmd("edit " .. err.file)
    vim.api.nvim_win_set_cursor(0, {err.lnum, (err.col or 1) - 1})
end

--- Jump to the error under cursor or at current index
function M.goto_error()
    -- TODO: implement
end

--- Kill the currently running compilation job
function M.kill()
    local buffer = require("zemac.buffer")
    local job_id = buffer.get_job()

    if job_id then
        vim.fn.jobstop(job_id)
        buffer.set_job(nil) -- Clear the job reference
        buffer.append({ "", "[Compilation killed]" })
    else
        vim.notify("No compilation running", vim.log.levels.INFO)
    end
end

--- Navigate to previous command in history
function M.history_prev()
    if #M.command_history == 0 then
        return
    end

    M.history_index = math.min(M.history_index + 1, #M.command_history)
    local cmd = M.command_history[#M.command_history - M.history_index + 1]

    -- Update line 1 in buffer
    local buffer = require("zemac.buffer")
    if buffer.bufnr and vim.api.nvim_buf_is_valid(buffer.bufnr) then
        vim.api.nvim_buf_set_lines(buffer.bufnr, 0, 1, false, { cmd })
    end
end

--- Navigate to next command in history
function M.history_next()
    if M.history_index <= 0 then
        return
    end

    M.history_index = M.history_index - 1
    local cmd
    if M.history_index == 0 then
        cmd = "" -- Empty for new command
    else
        cmd = M.command_history[#M.command_history - M.history_index + 1]
    end

    local buffer = require("zemac.buffer")
    if buffer.bufnr and vim.api.nvim_buf_is_valid(buffer.bufnr) then
        vim.api.nvim_buf_set_lines(buffer.bufnr, 0, 1, false, { cmd })
    end
end

return M
