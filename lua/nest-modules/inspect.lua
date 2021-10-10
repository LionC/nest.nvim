local module = {}
module.api = {}

local mappings = {}

module.api.getMappings = function()
    return mappings
end

module.saveMapping = function(config, rhs, name)
    table.insert(
        mappings,
        vim.tbl_extend(
            "force",
            config,
            {
                rhs = type(rhs) == "function"
                    and "<Lua function>"
                    or rhs,
                name = name,
            }
        )
    )
end

local defaultConfig = { test = 'bla' }

local function setup(config)
    local mergedConfig = type(config) == 'table'
        and vim.tbl_extend("force", defaultConfig, config)
        or defaultConfig

    return module
end

return setup
