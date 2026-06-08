return {
  -- LSP config collection. With Neovim 0.11+, installed servers can be enabled
  -- automatically by mason-lspconfig.
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Minimal LSP defaults/keymaps, applied whenever an LSP attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("gr", vim.lsp.buf.references, "References")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            analyses = {
              unusedparams = true,
              staticcheck = true,
            },
          },
        },
      })
    end,
  },

  -- Install external language tools from inside Neovim:
  -- LSPs, formatters, linters, debug adapters, etc.
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  -- Bridge Mason and nvim-lspconfig.
  -- Use :LspInstall to install language servers by lspconfig name, e.g. lua_ls.
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "gopls",
        "pyright",
        "ruff",
        "clojure_lsp",
      },
      automatic_enable = true,
    },
  },

  -- Install non-LSP tools: formatters and debug adapters.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "goimports",
        "delve",
        "ruff",
        "zprint",
      },
      run_on_start = true,
      start_delay = 1000,
    },
  },

  -- Hy language syntax/filetype support.
  {
    "hylang/vim-hy",
    ft = { "hy" },
    init = function()
      vim.filetype.add({
        extension = {
          hy = "hy",
        },
      })
    end,
  },

  -- REPL-driven development.
  -- Clojure uses nREPL; Python and Hy use stdio REPLs started by Conjure.
  {
    "Olical/conjure",
    ft = { "clojure", "python", "hy" },
    init = function()
      -- Keep Conjure scoped to the languages we actually use here.
      vim.g["conjure#filetypes"] = { "clojure", "python", "hy" }

      -- Do not steal K from LSP hover.
      vim.g["conjure#mapping#doc_word"] = false

      -- Make the client mapping explicit.
      vim.g["conjure#filetype#clojure"] = "conjure.client.clojure.nrepl"
      vim.g["conjure#filetype#python"] = "conjure.client.python.stdio"
      vim.g["conjure#filetype#hy"] = "conjure.client.hy.stdio"

      -- Run REPLs through uv so they use the project's local .venv.
      -- This expects `uv` plus a project-local environment / pyproject setup.
      vim.g["conjure#client#python#stdio#command"] = "uv run python -iq"
      vim.g["conjure#client#hy#stdio#command"] = "uv run hy -iu -c=Ready!"
    end,
  },

  -- Better syntax highlighting and parsing.
  -- Use :TSInstall <language>, e.g. :TSInstall lua javascript typescript python.
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "neovim-treesitter/treesitter-parser-registry" },
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Start Treesitter highlighting when a parser exists for the filetype.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- Completion engine: LSP, paths, snippets, buffer words.
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      completion = {
        documentation = { auto_show = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
    opts_extend = { "sources.default" },
  },

  -- Formatting.
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofmt" },
        python = { "ruff_format" },
        clojure = { "zprint" },
      },
    },
  },

  -- External linting. Add linters only for languages where LSP is insufficient.
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {}
    end,
  },

  -- Debug Adapter Protocol client.
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP step out" },
    },
  },

  -- Go debugging through Delve.
  {
    "leoluz/nvim-dap-go",
    ft = { "go" },
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },

  -- Python debugging through debugpy, launched via uv.
  {
    "mfussenegger/nvim-dap-python",
    ft = { "python" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-python").setup("uv")
    end,
  },
}
