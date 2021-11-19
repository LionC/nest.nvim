-- This is an example integration to help future users implement their own nest.nvim integration
-- This integration will log your nest config for you by pretty printing your applyKeymaps config
--
--- @type NestIntegration
local module = {}
module.name = 'example';

-- Utility length function
local len = function(table)
  local length = 0;
  for _, _ in ipairs(table) do
    length = length +1
  end
  return length
end


--- This is run before the keymaps are bound
--- Use it to setup data structures before the applyKeymaps config is traversed
--- @param config table<number, NestNode>
module.on_init = function(config)
  print('nest.nvim starting keymap binding');
end

--- This will be called for every element in the applyKeymaps config.
--- Here you can pass the nest.nvim config to whatever library you're integrating with 
--- or build a different representation of the data to be applied in the on_complete function.
--- @param node NestIntegrationNode
--- @param node_settings NestSettings
module.handler = function (node, node_settings)

  -- If node.rhs is a table, this is a group of keymaps, if it is a string then it is a keymap
  local is_keymap_group = type(node.rhs) == 'table'

  if is_keymap_group then
    print('nest.nvim: ' .. node.lhs .. ' is group of ' .. len(node.rhs) .. ' keymaps.')
  else
    print('nest.nvim: ' .. node.lhs .. ' is keymap binding to ' .. node.rhs .. '.')
  end

  -- You can get different keymap settings from the node_settings object
  local msg = '    buffer: ' .. string.format('%s', node_settings.buffer) .. ' | mode: ' .. node_settings.mode .. ' | '
  if (node_settings.options.noremap) then
    msg = msg .. 'noremap,'
  end
  if node_settings.options.silent then
    msg = msg .. 'silent,'
  end
  if node_settings.options.expr then
    msg = msg .. 'expr'
  end
  print(msg)
end

--- This is run before the keymaps are bound
--- Use it cleanup or apply data that was created in the handler/on_init functions
module.on_complete = function()
  print('nest.nvim: finished keymap binding.');
end

return module;
