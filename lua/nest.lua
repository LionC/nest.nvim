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
module.functions = {}

local function registerFunction(func)
    table.insert(module.functions, func)

    return #module.functions
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
    local presets = presets or module.defaults
    local mergedPresets = mergeOptions(presets, config)

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
        and '<Cmd>lua require("nest").functions[' .. registerFunction(second) .. ']()<CR>'
        or second

    if mergedPresets.buffer then
        local buffer = mergedPresets.buffer == true
            and 0
            or mergedPresets.buffer

        vim.api.nvim_but_set_keymap(
            buffer,
            mergedPresets.mode,
            mergedPresets.prefix,
            rhs,
            mergedPresets.options
        )
    else
        vim.api.nvim_set_keymap(
            mergedPresets.mode,
            mergedPresets.prefix,
            rhs,
            mergedPresets.options
        )
    end
end

return module
