local M = {}

function M.check()
    vim.health.start("zemac")

    local config = require("zemac.config")
    if vim.tbl_isempty(config.options) then
        vim.health.error("setup() is not called")
    else
        vim.health.ok("Plugin initialized")
    end

    local compiler = { "gcc", "go", "rustc", "tsc", "python3", "luac" }
    for _, c in ipairs(compiler) do
        if vim.fn.executable(c) == 1 then
            vim.health.ok(c .. " found")
        else
            vim.health.info(c .. " not found (optional)")
        end
    end
end

return M
