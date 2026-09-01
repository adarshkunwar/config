return {
  'neovim/nvim-lspconfig',

  dependencies = {
    -- Automatically install LSPs and related tools
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP
    { 'j-hui/fidget.nvim', opts = {} },

    -- Lua development
    {
      'folke/neodev.nvim',
      opts = {
        library = {
          enabled = true,
          runtime = true,
          types = true,
          plugins = true,
        },
      },
    },
  },

  config = function()
    ---------------------------------------------------------------------------
    -- Diagnostics
    ---------------------------------------------------------------------------

    vim.diagnostic.config {
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,

      float = {
        border = 'rounded',
        source = true,
      },
    }

    ---------------------------------------------------------------------------
    -- LSP keymaps
    ---------------------------------------------------------------------------

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', {
        clear = true,
      }),

      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, {
            buffer = event.buf,
            desc = 'LSP: ' .. desc,
          })
        end

        -- Go to definition
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- Find references
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Go to implementation
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Type definition
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        -- Document symbols
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

        -- Workspace symbols
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- Rename
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Code actions
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        -- Hover documentation
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- Declaration
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Show diagnostics
        map('<leader>d', vim.diagnostic.open_float, 'Show Diagnostic')

        -- Next diagnostic
        map(']d', vim.diagnostic.goto_next, 'Next Diagnostic')

        -- Previous diagnostic
        map('[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')

        -----------------------------------------------------------------------
        -- Document highlighting
        -----------------------------------------------------------------------

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),

            callback = function(event2)
              vim.lsp.buf.clear_references()

              vim.api.nvim_clear_autocmds {
                group = 'kickstart-lsp-highlight',
                buffer = event2.buf,
              }
            end,
          })
        end

        -----------------------------------------------------------------------
        -- Inlay hints
        -----------------------------------------------------------------------

        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    ---------------------------------------------------------------------------
    -- LSP capabilities
    ---------------------------------------------------------------------------

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    ---------------------------------------------------------------------------
    -- Mason-managed LSP servers
    ---------------------------------------------------------------------------

    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },

            diagnostics = {
              globals = { 'vim' },
            },

            workspace = {
              library = {
                vim.env.VIMRUNTIME,
              },

              checkThirdParty = false,
            },

            completion = {
              callSnippet = 'Replace',
            },

            telemetry = {
              enable = false,
            },
          },
        },
      },
    }

    ---------------------------------------------------------------------------
    -- Mason
    ---------------------------------------------------------------------------

    require('mason').setup()

    local ensure_installed = vim.tbl_keys(servers)

    vim.list_extend(ensure_installed, {
      'stylua',
    })

    require('mason-tool-installer').setup {
      ensure_installed = ensure_installed,
    }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}

          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

          require('lspconfig')[server_name].setup(server)
        end,
      },
    }

    ---------------------------------------------------------------------------
    -- LTeX-LS Plus
    --
    -- Installed system-wide:
    --     ltex-ls-plus --version
    --
    -- We don't put this in Mason because you're managing it yourself.
    ---------------------------------------------------------------------------

    vim.lsp.config('ltex_plus', {
      cmd = { 'ltex-ls-plus' },

      filetypes = {
        'text',
        'markdown',
      },

      capabilities = capabilities,

      settings = {
        ltex = {
          language = 'en-US',

          -- Don't automatically correct anything.
          -- LanguageTool will provide diagnostics and code actions.
          diagnosticSeverity = 'information',

          -- Disable rules you don't want.
          disabledRules = {},
        },
      },
    })

    vim.lsp.enable 'ltex_plus'
  end,
}
