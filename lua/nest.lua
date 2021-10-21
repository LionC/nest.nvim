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

--- Applies the given `keymapConfig`, creating nvim keymaps
module.applyKeymaps = function (config, presets)
    local mergedPresets = mergeOptions(
        presets or module.defaults,
        config
    )

    local first = config[1]

    if type(first) == 'table' then
        for _, it in ipairs(config) do
            module.applyKeymaps(it, mergedPresets)
        end

        return
    end

    local second = config[2]

    mergedPresets.prefix = mergedPresets.prefix .. first

    if type(second) == 'table' then
        module.applyKeymaps(second, mergedPresets)
        return
    end

    local rhs = type(second) == 'function'
        and functionToRhs(second, mergedPresets.options.expr)
        or second

    -- Pass current keymap node to all handlers
    for _, handler in pairs(module.handlers) do
      handler(mergedPresets.buffer, mergedPresets.prefix, rhs, nil, nil, mergedPresets.mode, mergedPresets.options)
    end
end

module.handlers = {}

module.handlers['nest'] = function(buffer, lhs, rhs, _, _, mode, options)
    for m in string.gmatch(mode, '.') do
        local sanitizedMode = m == '_'
            and ''
            or mode

        if buffer then
            local b = (buffer == true)
                and 0
                or buffer

            vim.api.nvim_buf_set_keymap(
                b,
                sanitizedMode,
                lhs,
                rhs,
                options
            )
        else
            vim.api.nvim_set_keymap(
                m,
                lhs,
                rhs,
                options
            )
        end
    end
end

module.addMapHandler = function(name, handler)
  module.handlers[name] = handler
end

module.enableWhichkey = require('enable-whichkey')

return module
