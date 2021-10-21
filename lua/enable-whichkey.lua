return function ()
  local nest = require('nest.nvim')

  local keymapTable = {};

  local keymapHandler = function (buffer, lhs, rhs, name, description, mode, options)
    -- Create new property in table if doesn't exist
    if (keymapTable[lhs] == nil) then
      keymapTable[lhs] = {}
    end

    -- If this is a keymap group
    if type(rhs) == 'table' then
      keymapTable[lhs]['name'] = name
    -- If this is an actual keymap
    elseif (type(rhs) == 'string') then
      keymapTable[lhs][rhs] = name
    end
  end

  for prefix, mappings in pairs(keymapTable) do
    require("which-key").register(mappings, { prefix })
  end
  nest.addKeymapHander('whichkey', keymapHandler)
end
