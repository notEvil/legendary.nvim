local function parse_keymaps(keymaps, filters)
  local mappings = {}
  for _, keymap in ipairs(keymaps) do
    local desc = vim.tbl_get(keymap, 4, 'desc')
    if desc and #desc > 0 and desc ~= 'diffview_ignore' then
      table.insert(mappings, {
        keymap[2],
        description = string.format('Diffview: %s', desc),
        mode = keymap[1],
        filters = filters,
      })
    end
  end
  return mappings
end

local function diffview_is_open()
  return require('diffview.lib').get_current_view() ~= nil
end

local function diffview_type_matches(type)
  return function()
    local view = require('diffview.lib').get_current_view()
    return view ~= nil and vim.startswith(view.cur_layout.name, type)
  end
end

return function()
  require('legendary.extensions').pre_ui_hook(function()
    -- we need to wait until the user has applied their own config.
    -- as a best approximation, we can wait until `diffview` has been loaded
    if not package.loaded['diffview'] then
      return false
    end

    local ok, diffview_cfg = pcall(require, 'diffview.config')
    if not ok then
      return false
    end

    local keymaps = diffview_cfg.get_config().keymaps
    local legendary_keymaps = {}
    for key, mappings in pairs(keymaps) do
      if key == 'option_panel' or key == 'help_panel' or key == 'disable_defaults' then
        -- no op
      elseif key == 'view' then -- these apply to all diffview view types
        legendary_keymaps = vim.list_extend(legendary_keymaps, parse_keymaps(mappings, { diffview_is_open }))
      elseif key == 'file_panel' then
        legendary_keymaps = vim.list_extend(legendary_keymaps, parse_keymaps(mappings, { filetype = 'DiffviewFiles' }))
      elseif key == 'file_history_panel' then
        legendary_keymaps =
          vim.list_extend(legendary_keymaps, parse_keymaps(mappings, { filetype = 'DiffviewFileHistory' }))
      else
        -- e.g. the layout name will be "diff2_horizontal"
        legendary_keymaps = vim.list_extend(legendary_keymaps, parse_keymaps(mappings, { diffview_type_matches(key) }))
      end
    end
    require('legendary').keymaps(legendary_keymaps)
    return true
  end)
end
