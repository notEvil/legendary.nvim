# Lua API

You can also manually bind new items after you've already called `require('legendary').setup()`.
This can be useful for things like binding language-specific keyaps in the LSP `on_attach` function.

The main API functions are described below. To see full API documentation, run `:LegendaryApi`.

## Binding Keymaps, Commands, Autocmds, and Functions

```lua
-- bind a single keymap
require('legendary').keymap(keymap)
-- bind a list of keymaps
require('legendary').keymaps({
  -- your keymaps here
})

-- bind a single command
require('legendary').command(command)
-- bind a list of commands
require('legendary').commands({
  -- your commands here
})

-- bind a single function table
require('legendary').func(fn_tbl)
-- bind a list of functions
require('legendary').funcs({
  -- your function tables here
})

-- bind a single augroup/autocmds
require('legendary').autocmd(augroup_or_autocmd)
-- bind a list of augroups/autocmds
require('legendary').autocmds({
  -- your augroups and autocmds here
})

-- bind a single item group
require('legendary').itemgroup(itemgroups)
require('legendary').itemgroups({
  {
    itemgroup = 'Item group 1...',
    keymaps = {
      -- keymaps here
    },
    commands = {
      -- commands here
    },
    funcs = {
      -- functions here
    },
  },
  {
    itemgroup = 'Item group 2...',
    keymaps = {},
    commands = {},
    funcs = {},
  },
})

-- search keymaps, commands, functions, and autocmds
require('legendary').find()

-- the following item type filters also include ItemGroups,
-- if an ItemGroup is selected, its items will be filtered
-- using the same item type filter

-- search keymaps
require('legendary').find({ filters = { require('legendary.filters').keymaps() } })
-- search commands
require('legendary').find({ filters = { require('legendary.filters').commands() } })
-- search functions
require('legendary').find({ filters = { require('legendary.filters').funcs() } })
-- search autocmds
require('legendary').find({ filters = { require('legendary.filters').autocmds() } })

-- filter keymaps by current mode;
-- only keymaps are filtered, since other
-- item types are not mode-specific
require('legendary').find({
  filters = { require('legendary.filters').current_mode() },
})

-- find only keymaps, and filter by current mode
require('legendary').find({
  filters = {
    require('legendary.filters').current_mode(),
    require('legendary.filters').keymap(),
  },
})
-- filter keymaps by normal mode
require('legendary').find({
  filters = require('legendary.filters').mode('n')
})
-- filter keymaps by normal mode and that start with <leader>
require('legendary').find({
  filters = {
    require('legendary.filters').mode('n'),
    function(item)
      return require('legendary.toolbox').is_keymap(item) and vim.startswith(item[1], '<leader>')
    end
  }
})
```

## Converting Keymaps From Vimscript

Keymaps can be parsed from Vimscript commands (e.g. `vnoremap <silent> <leader>f :SomeCommand<CR>`).

```lua
-- Function signature
require('legendary.toolbox').table_from_vimscript(vimscript_str, description)
-- For example
require('legendary.toolbox').table_from_vimscript(
  ':vnoremap <silent> <expr> <leader>f :SomeCommand<CR>',
  'Description of my keymap'
)
-- Returns the following table
{
  '<leader>f',
  ':SomeCommand<CR>',
  description = 'Description of my keymap',
  mode = 'v',
  opts = {
    silent = true,
    expr = true,
    remap = false,
  },
}
```
