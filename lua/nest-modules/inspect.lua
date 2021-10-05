local module = {}

local mappings = {}

module.getMappings = function()
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

return module
