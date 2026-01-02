---@class Zemac.Parser
local M = {}

--- Error patterns for different compilers/tools
--- Order matters: more specific patterns should come first
---@type { name: string, pattern: string, groups: string[] }[]
M.patterns = {
    -- GCC/Clang with column: file:line:col: type: message
    {
        name = "gcc",
        pattern = "^([^:]+):(%d+):(%d+): (%w+): (.+)$",
        groups = { "file", "lnum", "col", "type", "text" },
    },
}

--- Try to match a line against all patterns
---@param line string The line to parse
---@param buffer_line number The line number in the compile buffer
---@return Zemac.Error|nil
function M.parse_line(line, buffer_line)
    if not line or line == "" then
        return nil
    end

    for _, pat in ipairs(M.patterns) do
        -- string.match returns all captures if match
        local capture = { string.match(line, pat.pattern) }

        if #capture > 0 then
            local err = { buffer_line = buffer_line }

            for i, group in ipairs(pat.groups) do
                local value = capture[i]

                if group == "lnum" or group == "col" then
                    err[group] = tonumber(value) or 1
                else
                    err[group] = value
                end
            end

            err.file = M.find_full_path(err.file)
            err.lnum = err.lnum
            err.col = err.col
            err.text = err.text
            err.type = err.type
            return err
        end
    end

    return nil
end

--- Parse all lines in a buffer for errors
---@param bufnr number Buffer number to parse
---@return Zemac.Error[]
function M.parse_buffer(bufnr)
    local buffer = require("zemac.buffer")
    local errors = {}

    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return errors
    end

    -- skip header lines
    local lines =
        vim.api.nvim_buf_get_lines(bufnr, buffer.HEADER_LINES, -1, false)
    for i, line in ipairs(lines) do
        local buffer_line = buffer.HEADER_LINES + i
        local error = M.parse_line(line, buffer_line)
        if error then
            table.insert(errors, error)
        end
    end

    return errors
end

function M.find_full_path(file)
    local found = vim.fn.findfile(file, "**")
    if found ~= "" then
        file = found
    end

    return file
end

return M
