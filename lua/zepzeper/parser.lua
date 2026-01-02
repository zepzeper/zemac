---@class Zepzeper.Parser
local M = {}

---@alias Zepzeper.PatternName "gcc" | "lua" | "rust" | "generic"

---@class Zepzeper.Pattern
---@field name Zepzeper.PatternName Pattern identifier
---@field pattern string Lua pattern string
---@field groups string[] Named groups in order: file, lnum, col, type, text

--- Parse a single line for error information
---@param line string The line to parse
---@param line_num number The line number in the buffer
---@return Zepzeper.Error|nil error Parsed error or nil if no match
function M.parse_line(line, line_num)
    -- TODO: implement
    return nil
end

--- Parse the entire buffer for errors
---@param bufnr number Buffer number to parse
---@return Zepzeper.Error[] errors List of parsed errors
function M.parse_buffer(bufnr)
    -- TODO: implement
    return {}
end

return M
