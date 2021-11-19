--- @type NestIntegration
local module = {}
module.name = 'whichkey';

local keymap_table = {};

--- Handles each node of the nest keymap config (except the top level)
--- @param node NestIntegrationNode
--- @param node_settings NestSettings
module.handler = function (node, node_settings)
  -- Only handle <leader> keys, which key needs a 'Name' field
  if (node.lhs:find('<leader>') == nil or node.name == nil) then
    return
  end

  -- If this is a keymap group
  if type(node.rhs) == 'table' then
    keymap_table[node.lhs] = { name = node.name }
  -- If this is an actual keymap
  elseif (type(node.rhs) == 'string') then
    keymap_table[node.lhs] = { node.name }
  end
end

module.on_complete = function ()
  require("which-key").register(keymap_table)
end

return module;
