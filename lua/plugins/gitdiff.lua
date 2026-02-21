return {
  "sindrets/diffview.nvim",
  event = "User AstroGitFile",
  cmd = { "DiffviewOpen" },
  opts = {
    enhanced_diff_hl = false,
    view = {
      default = { winbar_info = true },
      file_history = { winbar_info = false },
    },
    hooks = { diff_buf_read = function(bufnr) vim.b[bufnr].view_activated = true end },
  },
  config = function(_, opts)
    require("diffview").setup(opts)
    local watcher = vim.uv.new_fs_event()
    watcher:start(vim.uv.cwd(), { recursive = true }, function(err)
      if err then return end
      vim.schedule(function()
        if #require("diffview.lib").views > 0 then vim.cmd "DiffviewRefresh" end
      end)
    end)

    local timer = vim.uv.new_timer()
    timer:start(500, 500, function()
      vim.schedule(function()
        if #require("diffview.lib").views > 0 then
          vim.cmd "DiffviewRefresh"
          vim.cmd "checktime"
        end
      end)
    end)

    local function refresh_diffview()
      if #require("diffview.lib").views > 0 then vim.cmd "DiffviewRefresh" end
    end
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufAdd", "FocusGained" }, {
      callback = refresh_diffview,
    })
  end,
  specs = {
    {
      "NeogitOrg/neogit",
      optional = true,
      opts = { integrations = { diffview = true } },
    },
  },
}
