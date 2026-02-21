local reg_win = nil

vim.api.nvim_create_user_command("Registers", function()
  if reg_win and vim.api.nvim_win_is_valid(reg_win) then
    vim.api.nvim_win_close(reg_win, true)
    reg_win = nil
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)

  local function refresh()
    local lines = vim.split(vim.fn.execute "registers", "\n", { plain = true })
    if lines[1] == "" then table.remove(lines, 1) end
    for i, line in ipairs(lines) do
      lines[i] = line:sub(6)
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
  end

  refresh()
  vim.cmd "botright vsplit"
  reg_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(reg_win, buf)

  local augroup = vim.api.nvim_create_augroup("RegistersRefresh", { clear = true })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then refresh() end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    buffer = buf,
    callback = function()
      vim.api.nvim_del_augroup_by_id(augroup)
      reg_win = nil
    end,
  })

  for _, key in ipairs { "q", "<Esc>" } do
    vim.keymap.set("n", key, function()
      vim.api.nvim_win_close(reg_win, true)
      reg_win = nil
    end, { buffer = buf, silent = true })
  end
end, {})

return {}
