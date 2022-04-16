--- @type NestIntegration
local module = {}
module.name = 'whichkey';

local keymaps = {
};

--- Handles each node of the nest keymap config (except the top level)
--- @param node NestIntegrationNode
--- @param node_settings NestSettings
module.handler = function (node, node_settings)
  -- Only handle <leader> keys, which key needs a 'Name' field
  if (node.lhs:find('<leader>') == nil or node.name == nil) then
    return
  end

  for _, v in ipairs(vim.split(node_settings.mode or "n", "")) do
    if keymaps[v] == nil then
      keymaps[v] = {}
    end
    -- If this is a keymap group
    if type(node.rhs) == 'table' then
      keymaps[v][node.lhs] = { name = node.name }
    -- If this is an actual keymap
    elseif (type(node.rhs) == 'string') then
      keymaps[v][node.lhs] = { node.name }
    end
  end

end

module.on_complete = function ()
  for k, v in pairs(keymaps) do
    require("which-key").register(v, { mode = k })
  end
end

return module;
