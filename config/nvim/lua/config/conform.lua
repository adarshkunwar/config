return {
  {
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format {
            async = true,
            lsp_fallback = true,
          }
        end,
        mode = 'n',
        desc = '[F]ormat buffer',
      },
      {
        '<leader>tf',
        function()
          if vim.b.conform_format_on_save ~= nil then
            vim.b.conform_format_on_save = not vim.b.conform_format_on_save
            print('Conform format-on-save (buffer): ' .. tostring(vim.b.conform_format_on_save))
          else
            vim.g.conform_format_on_save = not vim.g.conform_format_on_save
            print('Conform format-on-save (global): ' .. tostring(vim.g.conform_format_on_save))
          end
        end,
        mode = 'n',
        desc = '[T]oggle [F]ormat on save',
      },
    },
    opts = {
      notify_on_error = false,

      format_on_save = function(bufnr)
        -- buffer-local override takes precedence
        local enabled = vim.b[bufnr].conform_format_on_save ~= nil and vim.b[bufnr].conform_format_on_save or vim.g.conform_format_on_save

        if not enabled then
          return nil
        end

        local disable_filetypes = {
          c = true,
          cpp = true,
        }

        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,

      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd', 'prettier' },
        typescript = { 'prettierd', 'prettier' },
        javascriptreact = { 'prettierd', 'prettier' },
        typescriptreact = { 'prettierd', 'prettier' },
      },

      prettier = {
        extra_args = {
          '--single-quote',
          'true',
          '--trailing-comma',
          'all',
          '--print-width',
          '60',
          '--bracket-same-line',
          'false',
          '--prose-wrap',
          'always',
        },
      },
    },
  },
}
