local period = 500
local stop_autorefresh = nil

return {
  "sindrets/diffview.nvim",
  event = "User AstroGitFile",
  cmd = { "DiffviewOpen", "DiffviewAutorefresh" },
  opts = {
    enhanced_diff_hl = false,
    view = {
      default = { winbar_info = true },
      file_history = { winbar_info = false },
    },
    hooks = {
      diff_buf_read = function(bufnr)
        vim.b[bufnr].view_activated = true
        vim.bo[bufnr].readonly = true
      end,
      view_closed = function()
        if stop_autorefresh then
          stop_autorefresh()
          stop_autorefresh = nil
        end
      end,
    },
  },
  config = function(_, opts)
    require("diffview").setup(opts)

    vim.api.nvim_create_user_command("DiffviewAutorefresh", function(args)
      vim.cmd("DiffviewOpen " .. args.args)

      local watcher = vim.uv.new_fs_event()
      watcher:start(vim.uv.cwd(), { recursive = true }, function(err)
        if err then return end
        vim.schedule(function()
          if vim.fn.getcmdwintype() == "" then vim.cmd "DiffviewRefresh" end
        end)
      end)

      local timer = vim.uv.new_timer()
      timer:start(period, period, function()
        vim.schedule(function()
          if vim.fn.getcmdwintype() == "" then
            vim.cmd "DiffviewRefresh"
            vim.cmd "checktime"
          end
        end)
      end)

      local autocmd_id = vim.api.nvim_create_autocmd({ "BufWritePost", "BufAdd", "FocusGained" }, {
        callback = function()
          if vim.fn.getcmdwintype() == "" then vim.cmd "DiffviewRefresh" end
        end,
      })

      stop_autorefresh = function()
        watcher:close()
        timer:close()
        vim.api.nvim_del_autocmd(autocmd_id)
      end
    end, { nargs = "*" })
  end,
  specs = {
    {
      "NeogitOrg/neogit",
      optional = true,
      opts = { integrations = { diffview = true } },
    },
  },
}
