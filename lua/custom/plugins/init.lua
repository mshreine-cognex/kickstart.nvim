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
vim.keymap.set('n', '<leader>tf', function()
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

-- Wipe out all background buffers
vim.keymap.set('n', '<leader>bw', ':.+,$bwipeout<CR>', { desc = 'Wipeout background buffers' })
which.add {
  { '<leader>b', group = '[B]uffers' },
}

return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    enabled = true,
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      ---@diagnostic disable-next-line
      harpoon.setup {}

      -- basic telescope configuration
      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set('n', '<leader>ua', function()
        harpoon:list():add()
      end, { desc = '[A]dd file' })
      vim.keymap.set('n', '<leader>uf', function()
        toggle_telescope(harpoon:list())
      end, { desc = 'Open Telescope Harpoon ' })
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Toggle harpoon menu' })
      vim.keymap.set('n', '<leader>u1', function()
        harpoon:list():select(1)
      end, { desc = 'Go to 1 in harpoon list' })
      vim.keymap.set('n', '<leader>u2', function()
        harpoon:list():select(2)
      end, { desc = 'Go to 2 in harpoon list' })
      vim.keymap.set('n', '<leader>u3', function()
        harpoon:list():select(3)
      end, { desc = 'Go to 3 in harpoon list' })
      vim.keymap.set('n', '<leader>u4', function()
        harpoon:list():select(4)
      end, { desc = 'Go to 4 in harpoon list' })
      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<leader>up', function()
        harpoon:list():prev()
      end, { desc = '[P]rev' })
      vim.keymap.set('n', '<leader>un', function()
        harpoon:list():next()
      end, { desc = '[N]ext' })

      local wkey = require 'which-key'
      wkey.add({
        { '<leader>u', group = 'Harpoon' },
      }, {})

      -- Extend the harpoon actions
      harpoon:extend {
        UI_CREATE = function(cx)
          vim.keymap.set('n', '<C-v>', function()
            harpoon.ui:select_menu_item { vsplit = true }
          end, { buffer = cx.bufnr })

          vim.keymap.set('n', '<C-x>', function()
            harpoon.ui:select_menu_item { split = true }
          end, { buffer = cx.bufnr })

          vim.keymap.set('n', '<C-t>', function()
            harpoon.ui:select_menu_item { tabedit = true }
          end, { buffer = cx.bufnr })
        end,
      }
    end,
  },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
        copilot_node_command = vim.fn.expand '$HOME/' .. '.nvm/versions/node/v20.19.0/bin/node',
      }
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
