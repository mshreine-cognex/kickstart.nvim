-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
--
local which = require 'which-key'

-- Key map for new split terminal
vim.keymap.set('n', '<leader>nst', function()
  vim.cmd.vnew()
  vim.cmd.term()
  -- vim.cmd.wincmd 'J'
end, { desc = '[N]ew [S]plit [T]erminal' })

-- Floating terminal
local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}
local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  -- Create a buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end
  -- Define a window configuration
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
  }
  local win = vim.api.nvim_open_win(buf, true, win_config)
  return { buf = buf, win = win }
end
vim.keymap.set({ 'n', 't' }, '<leader>tf', function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end, { desc = '[T]oggle [F]loating Terminal' })
-- END Floating Terminal

which.add({
  { '<leader>n', group = '[N]ew' },
  { '<leader>ns', group = '[N]ew [S]plit' },
}, {})

return {}
