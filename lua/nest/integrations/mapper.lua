local module = {}
module.name = 'mapper';

local unique_id_table = {};

local determine_uid = function (rhs, name)
  -- Format name to snake case no punctuation
  local formatted_name = name:lower()
  formatted_name = formatted_name:gsub("%p", '')
  formatted_name = formatted_name:gsub("%s", "_")

  local n = formatted_name
  local i = 0
  -- Find a free spot in the unique_id_table
  while unique_id_table[n] ~= nil and i < 50 do
    i = i + 1
    n = formatted_name .. "_" .. i
    -- If this command has already been added, return early
    if unique_id_table[n] == rhs then
      return
    end
  end

  -- Add to table
  unique_id_table[n] = rhs

  return n
end

-- Categories are generated from the name of the parent keymap group
local category_table = {}
local add_category = function (lhs, name) 
  print('Adding group ' .. lhs .. ' as ' .. name)
  category_table[lhs] = name
end
local get_category_for_command = function(lhs)
  local key = lhs:sub(1, -2)
  print('searching for command ' .. key)
  return category_table[key]
end

Mapper = require("nvim-mapper")
-- @description Handles the each node in the nest tree
-- @param buffer number|nil
-- @param lhs string
-- @param rhs string|table
-- @param name string|nil
-- @param description string|nil
-- @param mode string
-- @param options table
module.handler = function (buffer, lhs, rhs, name, description, mode, options)
  if name == nil then
    return
  end

  if type(rhs) == 'table' then
    -- If a name is provided, save the category
    print('adding category for ' .. lhs)
    add_category(lhs, name)
    return
  end

  local category = get_category_for_command(lhs)
  local id = determine_uid(lhs, name)

  -- Fallback to name if description not provided
  local _description = description == nil and name or description
  print(lhs)
  print(category)
  print(id)
  print(_description)
  if category == nil or id == nil or _description == nil then
    return;
  end

  if buffer ~= nil then
    Mapper.map_buf(buffer, mode, lhs, rhs, options, category, id, _description)
  else
    Mapper.map(mode, lhs, rhs, options, name, id, _description)
  end
end

return module;
