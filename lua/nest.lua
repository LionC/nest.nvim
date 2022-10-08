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

local function mergeOptions(left, right)
    if right == nil then
        return left or {}
    end

    local ret = vim.tbl_deep_extend("force", left, right) or {}

    if right.prefix ~= nil then
        ret.prefix = left.prefix .. right.prefix
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
end

return module
