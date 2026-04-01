return {
  "sindrets/diffview.nvim",
  config = function()
    require("diffview").setup {}

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
