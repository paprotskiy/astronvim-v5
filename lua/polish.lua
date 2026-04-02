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

-- Fix: astrocore's large file detection caches results by bufnr but never clears them on BufDelete.
-- When Neovim reuses a bufnr, a small file can inherit a stale "large" result from a previous file.
-- Replace is_large with a no-cache version that also guards against division-by-zero (line_count=0).
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local astro_buf = require "astrocore.buffer"
    astro_buf.is_large = function(bufnr, large_buf_opts)
      if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
      if not vim.api.nvim_buf_is_loaded(bufnr) then return false end
      if not large_buf_opts then large_buf_opts = vim.tbl_get(require("astrocore").config, "features", "large_buf") end
      if not large_buf_opts then return false end
      local enabled = large_buf_opts.enabled
      if type(enabled) == "function" then
        large_buf_opts = vim.deepcopy(large_buf_opts)
        enabled = enabled(bufnr, large_buf_opts)
        if type(enabled) == "table" then large_buf_opts = enabled end
      end
      if vim.F.if_nil(enabled, true) == false then return false end
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      local file_size = ok and stats and stats.size or 0
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local too_large = large_buf_opts.size and file_size > large_buf_opts.size
      local too_long = large_buf_opts.lines and line_count > large_buf_opts.lines
      local too_wide = large_buf_opts.line_length and line_count > 0 and (file_size / line_count) - 1 > large_buf_opts.line_length
      return too_large or too_long or too_wide or false
    end
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
