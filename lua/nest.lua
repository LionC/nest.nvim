local module = {}

--- Defaults being applied to `applyKeymaps`
-- Can be modified to change defaults applied.
module.defaults = {
    mode = "n",
    prefix = "",
    buffer = false,
    options = {
        noremap = true,
        silent = true,
    },
}

--- Registry for keymapped lua functions, do not modify!
module.rhsFns = {}

local function functionToRhs(func, expr)
    table.insert(
        module.rhsFns,
        expr
            and function() print(func()) end
            or func
    )

    return '<Cmd>lua require("nest").rhsFns[' .. #module.rhsFns .. ']()<CR>' 
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

    if type(first) == "table" then
        for _, it in ipairs(config) do
            module.applyKeymaps(it, mergedPresets)
        end

        return
    end

    local second = config[2]

    mergedPresets.prefix = mergedPresets.prefix .. first

    if type(second) == "table" then
        module.applyKeymaps(second, mergedPresets)

        return
    end

    local rhs = type(second) == "function"
        and functionToRhs(second, mergedPresets.options.expr)
        or second

    for mode in string.gmatch(mergedPresets.mode, '.') do
        if mergedPresets.buffer then
            local buffer = (mergedPresets.buffer == true)
                and 0
                or mergedPresets.buffer

            vim.api.nvim_buf_set_keymap(
                buffer,
                mode,
                mergedPresets.prefix,
                rhs,
                mergedPresets.options
            )
        else
            vim.api.nvim_set_keymap(
                mode,
                mergedPresets.prefix,
                rhs,
                mergedPresets.options
            )
        end
    end

end

return module
