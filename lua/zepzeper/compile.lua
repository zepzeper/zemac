---@class Zepzeper.Compile
---@field last_command string|nil Last executed compile command
---@field errors Zepzeper.Error[] List of parsed errors
---@field current_error_idx number Current error index for navigation
local M = {}

---@class Zepzeper.Error
---@field file string File path
---@field lnum number Line number
---@field col number Column number
---@field text string Error message text
---@field type? string Error type (error, warning, etc.)

---@type string|nil
M.last_command = nil
---@type Zepzeper.Error[]
M.errors = {}
---@type number
M.current_error_idx = 0

--- Run a compile command
---@param cmd? string Command to run (uses default if nil)
function M.run(cmd)
    local command = cmd or "make lua_fmt"
    M.last_command = command

    local buffer = require("zepzeper.buffer")
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
            end)
        end,
    })

    buffer.set_job(job_id)
end

--- Recompile using the last command
function M.recompile()
    if M.last_command then
        M.run(M.last_command)
    end

    vim.notify("Failed to recompile last command not found")
end

--- Jump to the next error in the list
function M.next_error()
    -- TODO: implement
end

--- Jump to the previous error in the list
function M.prev_error()
    -- TODO: implement
end

--- Jump to the error under cursor or at current index
function M.goto_error()
    -- TODO: implement
end

--- Kill the currently running compilation job
function M.kill()
    local buffer = require("zepzeper.buffer")
    local job_id = buffer.get_job()

    if job_id then
        vim.fn.jobstop(job_id)
        buffer.set_job(nil) -- Clear the job reference
        buffer.append({ "", "[Compilation killed]" })
    else
        vim.notify("No compilation running", vim.log.levels.INFO)
    end
end

return M
