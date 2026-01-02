local M = {}

M.last_command = nil
M.errors = {}
M.current_error_idx = 0

function M.run(cmd)
    local command = cmd or "make lua_fmt"
    M.last_command = command

    local buffer = require("zepzeper.buffer")
    buffer.clear()
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

function M.recompile()
    if M.last_command then
        M.run(M.last_command)
    end

    vim.notify("Failed to recompile last command not found")
end

function M.next_error()
    -- TODO: implement
end

function M.prev_error()
    -- TODO: implement
end

function M.goto_error()
    -- TODO: implement
end

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
