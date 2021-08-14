local module = {}

--- Defaults used for `applyKeybinds`
-- You can set these to override them. Defaults are:
--
-- @field mode Mode for the keybindings. Defaults to `'n'`. See @see vim.api.nvim_set_keymap
-- @field options Keybind options like `<buffer>` and `<silent>` as a table of booleans. Defaults to `{ noremap = true, silent = true }`. See @see vim.api.nvim_set_keymap
-- @field prefix Prefix being applied to **all** (left side) key sequences. Defaults to an empty string (no prefix)
module.defaults = {
    mode = "n",
    options = {
        noremap = true,
        silent = true,
    },
    prefix = "",
}

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

    if (right == nil) then
        return ret
    end

    if (right.mode ~= nil) then
        ret.mode = right.mode
    end

    if (right.prefix ~= nil) then
        ret.prefix = ret.prefix .. right.prefix
    end

    if (right.options ~= nil) then
        ret.options = mergeTables(ret.options, right.options)
    end

    return ret
end

--- Applies the given keybinds using the current `defaults`
-- Keybinds can be passed as a list of configs, with each config
-- being one of three options:
--
-- 1. A pair of strings
-- 2. A pair of a string and another config
-- 3. A new list of configs
--
-- with each having optional properties to override the current `defaults`.
--
-- Example:
--
-- ```lua
-- ```
module.applyKeybinds = function (config, presets)
    local presets = presets or module.defaults
    local mergedPresets = mergeOptions(presets, config)

    local first = config[1]

    if(type(first) == "table") then
        for _, it in ipairs(config) do
            module.applyKeybinds(it, mergedPresets)
        end

        return
    end

    local second = config[2]

    mergedPresets.prefix = mergedPresets.prefix .. first

    if(type(second) == "table") then
        module.applyKeybinds(second, mergedPresets)

        return
    end

    vim.api.nvim_set_keymap(
        mergedPresets.mode,
        mergedPresets.prefix,
        second,
        mergedPresets.options
    )
end

return module
