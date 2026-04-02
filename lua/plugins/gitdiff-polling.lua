return {
  "sindrets/diffview.nvim",
  config = function()
    vim.opt.fillchars:append { diff = " " }
    require("diffview").setup {
      hooks = {
        diff_buf_win_enter = function(bufnr, winid, ctx)
          vim.defer_fn(function()
            if not vim.api.nvim_win_is_valid(winid) then return end
            if vim.wo[winid].winbar ~= "" then return end
            local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
            if name ~= "" then vim.wo[winid].winbar = name end
          end, 100)
        end,
      },
    }

    local poll_timer = nil

    local function stop_polling()
      if poll_timer then
        if not poll_timer:is_closing() then
          poll_timer:stop()
          poll_timer:close()
        end
        poll_timer = nil
        print "Diffview polling stopped"
      end
    end

    local function start_polling()
      if poll_timer then
        print "Diffview polling is already running"
        return
      end

      poll_timer = vim.loop.new_timer()
      poll_timer:start(
        0,
        500,
        vim.schedule_wrap(function()
          local view = require("diffview.lib").get_current_view()
          if view then
            vim.cmd "DiffviewRefresh"
          else
            -- Auto-kill if you close Diffview but forgot to stop polling
            stop_polling()
          end
        end)
      )
      print "Diffview polling started (0.5s)"
    end

    -- Create the manual commands
    vim.api.nvim_create_user_command("DiffviewPollStart", start_polling, {})
    vim.api.nvim_create_user_command("DiffviewPollStop", stop_polling, {})
  end,
}
