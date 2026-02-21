return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require "dap"
    local uv = vim.loop

    -- Utility: find all main packages
    local function find_mains()
      local cwd = vim.fn.getcwd()
      local mains = {}

      -- Check root
      local root_main = cwd .. "/main.go"
      if uv.fs_stat(root_main) then table.insert(mains, cwd) end

      -- Check cmd/*/main.go
      local handle = uv.fs_scandir(cwd .. "/cmd")
      if handle then
        while true do
          local name, _ = uv.fs_scandir_next(handle)
          if not name then break end
          local path = cwd .. "/cmd/" .. name .. "/main.go"
          if uv.fs_stat(path) then table.insert(mains, cwd .. "/cmd/" .. name) end
        end
      end

      -- fallback
      if #mains == 0 then table.insert(mains, cwd) end

      return mains
    end

    -- Interactive picker if multiple binaries
    local function pick_main()
      local mains = find_mains()
      if #mains == 1 then return mains[1] end
      local choices = {}
      for i, m in ipairs(mains) do
        table.insert(choices, i .. ": " .. m)
      end
      local idx = vim.fn.inputlist(choices)
      return mains[idx] or cwd
    end

    -- Go DAP configuration
    dap.configurations.go = {
      {
        type = "go",
        name = "Dynamic Debug",
        request = "launch",
        program = pick_main,
      },
    }

    -- Optional: set up adapter (Mason dlv)
    dap.adapters.go = {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fn.stdpath "data" .. "/mason/bin/dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
      },
    }
  end,
}
