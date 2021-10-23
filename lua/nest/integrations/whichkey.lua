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

  -- If this is a keymap group
  if type(rhs) == 'table' then
    keymap_table[lhs] = { name = name }
  -- If this is an actual keymap
  elseif (type(rhs) == 'string') then
    keymap_table[lhs] = { name }
  end
end

module.on_complete = function ()
  require("which-key").register(keymap_table)
end

return module;
