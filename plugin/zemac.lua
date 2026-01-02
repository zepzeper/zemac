if vim.g.loaded_zemac then
    return
end
vim.g.loaded_zemac = true

require("zemac.commands").setup()
