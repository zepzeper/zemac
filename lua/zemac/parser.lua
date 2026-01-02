---@class Zemac.Parser
local M = {}

--- Error patterns for different compilers/tools
---@type table<string, { pattern: string, groups: string[] }[]>
M.patterns_by_compiler = {
    gcc = {
        {
            pattern = "^([^:]+):(%d+):(%d+): (%w+): (.+)$",
            groups = { "file", "lnum", "col", "type", "text" },
        },
    },
    go = {
        {
            pattern = "^%.?/?([^:]+):(%d+):(%d+): (.+)$",
            groups = { "file", "lnum", "col", "text" },
        },
    },
    typescript = {
        {
            pattern = "^([^%(]+)%((%d+),(%d+)%): (%w+) %w+: (.+)$",
            groups = { "file", "lnum", "col", "type", "text" },
        }
    },
    python = {
        {
            pattern = '^%s*File "([^"]+)", line (%d+)',
            groups = { "file", "lnum" },
        },
    },
    lua = {
        {
            pattern = "^[%w]*:?%s*([^:]+):(%d+): (.+)$",
            groups = { "file", "lnum", "text" },
        },
    },
    rust = {
        {
            -- Matches: --> src/main.rs:15:5
            pattern = "^%s*%-%-?> ([^:]+):(%d+):(%d+)",
            groups = { "file", "lnum", "col" },
        },
    },
    all = {
        -- GCC/Clang: file:line:col: type: message
        {
            pattern = "^([^:]+):(%d+):(%d+): (%w+): (.+)$",
            groups = { "file", "lnum", "col", "type", "text" },
        },
        -- Rust: --> file:line:col
        {
            pattern = "^%s*%-%-?> ([^:]+):(%d+):(%d+)",
            groups = { "file", "lnum", "col" },
        },
        -- TypeScript: file(line,col): type CODE: message
        {
            pattern = "^([^%(]+)%((%d+),(%d+)%): (%w+) %w+: (.+)$",
            groups = { "file", "lnum", "col", "type", "text" },
        },
        -- Python: File "file", line N
        {
            pattern = '^%s*File "([^"]+)", line (%d+)',
            groups = { "file", "lnum" },
        },
        -- Go / generic: [./]file:line:col: message
        {
            pattern = "^%.?/?([^:]+):(%d+):(%d+): (.+)$",
            groups = { "file", "lnum", "col", "text" },
        },
        -- Lua / simple: file:line: message
        {
            pattern = "^[%w]*:?%s*([^:]+):(%d+): (.+)$",
            groups = { "file", "lnum", "text" },
        },
    }
}

--- Detect compiler from command string
---@param command string The compile command
---@return string|nil compiler The detected compiler name or nil
function M.detect_compiler(command)
    if not command then
        return nil
    end

    -- Check for direct compiler invocations
    if command:match("^gcc") or command:match("^g%+%+") or command:match("^clang") then
        return "gcc"
    elseif command:match("^go ") or command:match("^go$") then
        return "go"
    elseif command:match("^tsc") or command:match("^npx tsc") then
        return "typescript"
    elseif command:match("^python") then
        return "python"
    elseif command:match("^lua") then
        return "lua"
    elseif command:match("^rustc ") or command:match("^cargo") then
        return "rust"
    end

    -- For make, try to detect from target or just return nil for fallback
    return nil
end

--- Try to match a line against patterns
---@param line string The line to parse
---@param buffer_line number The line number in the compile buffer
---@param compiler string|nil The detected compiler
---@return Zemac.Error|nil
function M.parse_line(line, buffer_line, compiler)
    if not line or line == "" then
        return nil
    end

    local patterns = M.patterns_by_compiler[compiler]
    if patterns == nil then
        patterns = M.patterns_by_compiler["all"]
    end

    for _, pat in ipairs(patterns) do
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
            err.type = err.type or "error"
            return err
        end
    end

    return nil
end

--- Parse all lines in a buffer for errors
---@param bufnr number Buffer number to parse
---@param compiler string|nil Detected compiler to use for error parsing
---@return Zemac.Error[]
function M.parse_buffer(bufnr, compiler)
    local buffer = require("zemac.buffer")
    local errors = {}

    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return errors
    end

    -- Skip header lines
    local lines = vim.api.nvim_buf_get_lines(bufnr, buffer.HEADER_LINES, -1, false)
    for i, line in ipairs(lines) do
        local buffer_line = buffer.HEADER_LINES + i
        local err = M.parse_line(line, buffer_line, compiler)
        if err then
            table.insert(errors, err)
        end
    end

    return errors
end

--- Find full path for a file
---@param file string The filename to find
---@return string The resolved path or original filename
function M.find_full_path(file)
    -- Strip leading ./ if present
    file = file:gsub("^%./", "")

    local found = vim.fn.findfile(file, "**")
    if found ~= "" then
        return found
    end

    return file
end

return M
