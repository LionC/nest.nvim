local function findMaxLengths(lines)
    local maxLengths = {}

    for k, _ in pairs(lines[1]) do
        maxLengths[k] = 0
    end

    for _, line in ipairs(lines) do
        for k, v in pairs(line) do
            if #v > maxLengths[k] then
                maxLengths[k] = #v
            end
        end
    end

    return maxLengths
end

local function padColumns(lines, gap)
    local columnWidths = findMaxLengths(lines)

    for _, line in ipairs(lines) do
        for k, v in pairs(line) do
            line[k] = v .. string.rep(' ', columnWidths[k] + gap - #v)
        end
    end
end

local function mapppingToRow(mapping)
    return {
        prefix = mapping.prefix,
        rhs = mapping.rhs,
        tags = table.concat(mapping.tags or {}, ', '),
    }
end

local function rowToString(padding)
    local pad = string.rep(' ', padding)

    return function(row)
        return pad .. row.prefix .. row.rhs .. row.tags .. pad
    end
end

local function mappingsToTable(mappings)
    local ret = {
        { prefix = 'Keys', rhs = 'Mapped to', tags = 'Tags' },
        { prefix = '', rhs = '', tags = '', __isSeparator = true },
    }

    local rows = vim.list_extend(ret, vim.tbl_map(mapppingToRow, mappings))
    padColumns(rows, 2)
    local rowsWithSeparator = {}
    

    local lines = vim.tbl_map(rowToString(2), rows)
    local 
end

return function(mappings)
    local buf = vim.api.nvim_create_buf(false, true)
    local ui = vim.api.nvim_list_uis()[1]
    local width = ui.width - 10
    local height = ui.height - 8

    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = (ui.width/2) - (width/2),
        row = (ui.height/2) - (height/2),
        anchor = 'NW',
        style = 'minimal',
    }

    vim.api.nvim_open_win(buf, 1, opts)
    vim.api.nvim_buf_set_lines(
        buf,
        0,
        #mappings + 3,
        false,
        mappingsToTable(mappings)
    )
end

