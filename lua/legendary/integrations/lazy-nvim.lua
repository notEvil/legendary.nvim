local Log = require('legendary.log')

local M = {}

function M.load_lazy_nvim_keys()
  local has_lazy, _ = pcall(require, 'lazy')
  if not has_lazy then
    Log.warn("lazy.nvim integration is enabled, but cannot `require('lazy')`, aborting.")
    return
  end

  local LazyNvimConfig = require('lazy.core.config')
  local Handler = require('lazy.core.handler')
  for _, plugin in pairs(LazyNvimConfig.plugins) do
    local keys = Handler.handlers.keys:values(plugin)
    for _, keymap in pairs(keys) do
      if keymap.desc and #keymap.desc > 0 then
        -- we don't need the implementation, since
        -- lazy.nvim will have already bound it. We
        -- just need the description-only item to appear
        -- in the legendary.nvim finder.
        local legendary_keymap = {
          keymap[1], -- lhs
          description = keymap.desc,
          mode = keymap.mode, ---@type string|string[]|nil
        }
        require('legendary').keymap(legendary_keymap)
      end
    end
  end
end

return M
