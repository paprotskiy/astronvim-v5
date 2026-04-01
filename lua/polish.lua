-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.filetype.add {
  extension = {
    foo = "fooscript",
  },
  filename = {
    ["Foofile"] = "fooscript",
    ["tsconfig.json"] = "typescript",
    ["go.sum"] = "go",
    ["go.mod"] = "go",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.yml"] = "helm",
    [".*/applicationSet.yaml"] = "helm", -- INFO: hack for avoiding problems with argo-cd manifests autoformatting
  },
}

vim.api.nvim_create_augroup("neotree", {})
vim.api.nvim_create_autocmd("UiEnter", {
  desc = "Open Neotree automatically",
  group = "neotree",
  callback = function()
    -- if vim.fn.argc() == 0 then
    --   vim.cmd "Neotree toggle"
    --   vim.cmd "vertical resize 55"
    -- end
  end,
})

vim.cmd "highlight WinSeparator guibg=n"
vim.cmd "highlight NormalFloat guibg=n"
vim.cmd "highlight CursorLineNr guibg=n guifg=lightgray"
vim.cmd "highlight FoldColumn  guibg=n guifg=lightgray"

local run_claude = function(command)
  return function()
    local util = require "lspconfig.util"
    local root_dir = util.root_pattern(".git", "lua", "Makefile")(vim.fn.expand "%:p") or vim.loop.cwd() -- fallback if no root is found
    local dir = vim.fn.expand "%:p:h"

    vim.system({
      "sh",
      "-c",
      -- "zed " ..
      root_dir
        .. '& tmux split-window -h "cd '
        .. dir
        .. "&&"
        .. command
        .. '"',
    }, { detach = true })
  end
end

vim.keymap.set("n", "<leader>cn", run_claude "claude", {
  desc = "Claude Code",
})

vim.keymap.set("n", "<leader>cs", run_claude "claude --resume", {
  desc = "Claude Code (session list)",
})
