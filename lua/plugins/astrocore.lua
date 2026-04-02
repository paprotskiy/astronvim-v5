-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000, line_length = false }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,

        -- todo: move to clojure-tooling
        [",mo"] = {
          desc = "my-sexp: copy and vertical paste",
          callback = function()
            vim.cmd "normal vafy%"
            vim.cmd 'execute "normal! a\\<CR>"'
            vim.cmd "normal p"
          end,
        },
        [",mi"] = {
          desc = "my-sexp: insert list before",
          callback = function()
            vim.cmd "normal h"
            vim.api.nvim_put({ "()" }, "", true, true)
            vim.cmd "normal h"
            vim.cmd "startinsert"
          end,
        },
        [",ma"] = {
          desc = "my-sexp: insert list after",
          callback = function()
            vim.api.nvim_put({ "()" }, "", true, true)
            vim.cmd "normal h"
            vim.cmd "startinsert"
          end,
        },
        [",m'"] = {
          desc = "my-sexp: insert data form",
          callback = function()
            vim.api.nvim_put({ "'()" }, "", true, true)
            vim.cmd "normal h"
            vim.cmd "startinsert"
          end,
        },
        [",q"] = { desc = "my REPL ext" },
        [",ql"] = {
          desc = "REPL: prepare last command",
          callback = function()
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("q:", true, false, true))
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("kyyjp$", true, false, true))
          end,
        },
        [",qn"] = {
          desc = "REPL: new command",
          callback = function()
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("q:", true, false, true))
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("iConjureEval ", true, false, true))
          end,
        },
        ["<Leader>R"] = { "<Cmd>Registers<CR>", desc = "Registers" },

        ["gI"] = {
          function() vim.lsp.buf.implementation() end,
          desc = "Go to implementation",
        },

        ["<Leader>gw"] = {
          desc = "git blame for row",
          callback = function()
            require("gitsigns").setup {
              -- current_line_blame = false, -- Default is false
              current_line_blame_opts = {
                delay = 0, -- No delay for blame display
              },
            }
            vim.cmd "Gitsigns toggle_current_line_blame"
          end,
        },

        -- -- tables with just a `desc` key will be registered with which-key if it's installed
        -- -- this is useful for naming menus
        -- -- ["<Leader>b"] = { desc = "Buffers" },
        --
        -- -- setting a mapping to false will disable it
        -- -- ["<C-S>"] = false,
      },

      v = {
        [",qn"] = {
          desc = "REPL: new command",
          callback = function()
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("q:", true, false, true))
            -- vim.cmd "normal $"
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("AConjureEval", true, false, true))
          end,
        },
      },
    },
  },
}
