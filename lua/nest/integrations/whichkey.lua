local module = {}
module.name = 'whichkey';

local keymap_table = {};

-- @description Handles the each node in the nest tree
-- @param buffer number|nil
-- @param lhs string
-- @param rhs string|table
-- @param name string|nil
-- @param description string|nil
-- @param mode string
-- @param options table
module.handler = function (buffer, lhs, rhs, name, description, mode, options)
  -- Only handle <leader> keys, which key needs a 'Name' field
  if (lhs:find('<leader>') == nil or name == nil) then
    return
  end
--[[ 
  local node = keymap_table
  local distance_to_end = lhs:len()
  for c, l in lhs:gmatch"." do
    -- Creating nested keymaps
    if node[c] == nil and distance_to_end ~= 1 then
      node[c] = {}
    elseif distance_to_end == 1
      -- Once at at end of lhs, apply the name to that keymap
      node[c] = { name }
    end
  end

  if (keymap_table[lhs] == nil) then
    keymap_table[lhs] = {}
  end ]]

  -- If this is a keymap group
  if type(rhs) == 'table' then
    keymap_table[lhs]['name'] = name
  -- If this is an actual keymap
  elseif (type(rhs) == 'string') then
    keymap_table[lhs] = { name }
    print('Adding keymap ' .. lhs .. ' ' .. name)
  end
end

module.on_complete = function ()
  require("which-key").register(keymap_table, { prefix = '<leader>' })
end

return module;
