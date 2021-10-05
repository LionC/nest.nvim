local module = {}

local mappings = {}

module.getMappings = function()
    return mappings
end

module.saveMapping = function(config, rhs, description)
    table.insert(
        mappings,
        vim.tbl_extend(
            "force",
            config,
            {
                rhs = type(rhs) == "function"
                    and "<Lua function>"
                    or rhs,
                description = description,
            }
        )
    )
end

return module
