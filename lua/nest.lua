local module = {}

--- Defaults being applied to `applyKeymaps`
-- Can be modified to change defaults applied.
module.defaults = {
    mode = 'n',
    prefix = '',
    buffer = false,
    options = {
        noremap = true,
        silent = true,
    },
}

local rhsFns = {}

module._callRhsFn = function(index)
    rhsFns[index]()
end

module._getRhsExpr = function(index)
    local keys = rhsFns[index]()

    return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

local function functionToRhs(func, expr)
    table.insert(rhsFns, func)

    local insertedIndex = #rhsFns

    return expr
        and 'v:lua.package.loaded.nest._getRhsExpr(' .. insertedIndex .. ')'
        or '<cmd>lua package.loaded.nest._callRhsFn(' .. insertedIndex .. ')<cr>'
end

local function copy(table)
    local ret = {}

    for key, value in pairs(table) do
        ret[key] = value
    end

    return ret
end

local function mergeTables(left, right)
    local ret = copy(left)

    for key, value in pairs(right) do
        ret[key] = value
    end

    return ret
end

local function mergeOptions(left, right)
    local ret = copy(left)

    if right == nil then
        return ret
    end

    if right.mode ~= nil then
        ret.mode = right.mode
    end

    if right.buffer ~= nil then
        ret.buffer = right.buffer
    end

    if right.prefix ~= nil then
        ret.prefix = ret.prefix .. right.prefix
    end

    if right.options ~= nil then
        ret.options = mergeTables(ret.options, right.options)
    end

    return ret
end

-- Stores all the different handlers for the nest API
module.integrations = {}

-- Traverses the nest config and passes each node to module.integrations
module.traverse = function (config, presets)
    local mergedPresets = mergeOptions(
        presets or module.defaults,
        config
    )

    local first = config[1]

    if type(first) == 'table' then
        for _, it in ipairs(config) do
            module.traverse(it, mergedPresets)
        end

        return
    end

    local second = config[2]

    mergedPresets.prefix = mergedPresets.prefix .. first

    local rhs = type(second) == 'function'
        and functionToRhs(second, mergedPresets.options.expr)
        or second
    -- name is either the 3rd element in table or under the 'name' property
    local name = #config >= 3 and config[3] or config.name
    name = type(name) == 'string' and name or nil

    -- Apply keymaps if rhs is not a table
    if type(rhs) ~= 'table' then
      for mode in string.gmatch(mergedPresets.mode, '.') do
          local sanitizedMode = mode == '_'
              and ''
              or mode

          if mergedPresets.buffer then
              local buffer = (mergedPresets.buffer == true)
                  and 0
                  or mergedPresets.buffer

              vim.api.nvim_buf_set_keymap(
                  buffer,
                  sanitizedMode,
                  mergedPresets.prefix,
                  rhs,
                  mergedPresets.options
              )
          else
              vim.api.nvim_set_keymap(
                  sanitizedMode,
                  mergedPresets.prefix,
                  rhs,
                  mergedPresets.options
              )
          end
      end

    else -- If rhs is a table then we traverse into it
      module.traverse(second, mergedPresets)
    end

    -- Pass current keymap node to all integrations
    for _, integration in pairs(module.integrations) do
      integration.handler(mergedPresets.buffer, mergedPresets.prefix, rhs, name, nil, mergedPresets.mode, mergedPresets.options)
    end
end

-- Allows adding extra keymap integrations
module.enable = function(integration)
  if integration.name ~= nil then
    module.integrations[integration.name] = integration
  end
end

--- Applies the given `keymapConfig`, creating nvim keymaps
module.applyKeymaps = function(config, presets)
  -- Run on init for each integration
  for _, integration in pairs(module.integrations) do
    if integration.on_init ~= nil then
      integration.on_init(config)
    end
  end

  module.traverse(config, presets)

  for _, integration in pairs(module.integrations) do
    if integration.on_complete ~= nil then
      integration.on_complete()
    end
  end
end

return module
