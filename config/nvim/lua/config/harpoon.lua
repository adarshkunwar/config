local harpoon = require("harpoon")

harpoon.setup({})

vim.keymap.set('n', '<leader>a', function()
  harpoon.mark.add()
end, { desc = "Add Harpoon mark" })

vim.keymap.set('n', '<leader>e', function()
  harpoon.ui.toggle_quick_menu()
end, { desc = "Toggle Harpoon menu" })
