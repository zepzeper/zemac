if vim.g.loaded_zepzeper then
    return
end
vim.g.loaded_zepzeper = true

require("zepzeper.commands").setup()
