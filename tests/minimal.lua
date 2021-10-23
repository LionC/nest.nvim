vim.api.nvim_command('set rtp+=.')
vim.api.nvim_command('set rtp+=../which-key.nvim')

local nest = require('nest')
nest.enable(require('nest.integrations.whichkey'));
nest.applyKeymaps {
    -- Remove silent from ; : mapping, so that : shows up in command mode
    { ';', ':' , options = { silent = false } },
    { ':', ';' },

    -- Prefix  every nested keymap with <leader>
    { '<leader>', {
        -- Prefix every nested keymap with f (meaning actually <leader>f here)
        { 'f', name = '+File', {
            { 'f', '<cmd>Telescope find_files<cr>', 'Find Files' },
            -- This will actually map <leader>fl
            { 'l', '<cmd>Telescope live_grep<cr>', 'Search Files', },
            -- Prefix every nested keymap with g (meaning actually <leader>fg here)
            { 'g', name = '+Git', {
                { 'b', '<cmd>Telescope git_branches<cr>', 'Branches' },
                -- This will actually map <leader>fgc
                { 'c', '<cmd>Telescope git_commits<cr>', 'Commits' },
                { 's', '<cmd>Telescope git_status<cr>', 'Status' },
            }},
        }},

        -- Lua functions can be right side values instead of key sequences
        { 'l', name = '+Lsp', {
            { 'r', vim.lsp.buf.rename, 'Rename' },
            { 's', vim.lsp.buf.signature_help, 'Signature' },
            { 'h', vim.lsp.buf.hover, 'Hover' },
        }},
    }},

    -- Use insert mode for all nested keymaps
    { mode = 'i', {
        { 'jk', '<Esc>' },

        -- Set <expr> option for all nested keymaps
        { options = { expr = true }, {
            { '<cr>',       'compe#confirm("<CR>")' },
            -- This is equivalent to viml `:inoremap <C-Space> <expr>compe#complete()`
            { '<C-Space>',  'compe#complete()' },
        }},

        -- Buffer `true` sets keymaps only for the current buffer
        { '<C-', buffer = true, {
            { 'h>', '<left>' },
            { 'l>', '<right>' },
            -- You can also set bindings for a specific buffer
            { 'o>', '<Esc>o', buffer = 1 },
        }},
    }},

    -- Keymaps can be defined for multiple modes at once
    { 'H', '^', mode = 'nv' },
}
