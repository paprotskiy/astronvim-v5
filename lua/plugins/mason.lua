-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "clojure-lsp",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "eslint-lsp",
        "html-lsp",
        "emmet-language-server",
        "gopls",
        "yaml-language-server",
        "helm-ls",
        "omnisharp",
        "tombi",
        "buf",

        -- linters
        "clj-kondo",
        "golangci-lint",
        -- formatters
        "prettier",
        "eslint_d",
        "cljfmt",
        "stylua",
        "csharpier",

        -- install debuggers
        "go-debug-adapter",

        -- install any other package
        "tree-sitter-cli",
      },

      {
        "jay-babu/mason-null-ls.nvim",
        -- overrides `require("mason-null-ls").setup(...)`
        opts = {
          ensure_installed = {},
        },
      },
    },
  },
}
