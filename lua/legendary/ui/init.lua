local Config = require('legendary.config')
local State = require('legendary.data.state')
local Format = require('legendary.ui.format')

local M = {}

---@class LegendaryFindOpts
---@field filters LegendaryItemFilter[]
---@field prompt string|fun():string
---@field formatter LegendaryItemFormatter

---Select an item
---@param opts LegendaryFindOpts
---@param callback fun(item:LegendaryItem)
function M.select(opts, callback)
  opts = opts or {}
  local items = State.items:filter(opts.filters or {})
  local prompt = opts.select_prompt or Config.select_prompt
  if type(prompt) == 'function' then
    prompt = prompt()
  end

  local mode = vim.fn.mode()

  local padding = Format.compute_padding(items, opts.formatter or Config.default_item_formatter, mode)

  vim.ui.select(items, {
    prompt = prompt,
    format_item = function(item)
      return Format.format_item(item, opts.formatter or Config.default_item_formatter, padding, mode)
    end,
  }, function(selected)
    if selected and Config.most_recent_items_at_top then
      State.items:sort_inplace_by_recent(selected)
    end
    callback(selected)
  end)
end

return M
