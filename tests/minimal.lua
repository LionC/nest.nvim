vim.api.nvim_command('set rtp+=.')
vim.api.nvim_command('set rtp+=../which-key.nvim')

local wk = require("which-key")
wk.setup {}


local nest = require('nest')
nest.enable(require('nest.integrations.whichkey'));
nest.applyKeymaps {
    -- Remove silent from ; : mapping, so that : shows up in command mode
    { ';', ':' , options = { silent = false } },
    { ':', ';' },

    -- Prefix  every nested keymap with <leader>
    { '<leader>', {
        -- Prefix every nested keymap with f (meaning actually <leader>f here)
        { 'f', {
            { 'f', '<cmd>Telescope find_files<cr>' },
            -- This will actually map <leader>fl
            { 'l', '<cmd>Telescope live_grep<cr>' },
            -- Prefix every nested keymap with g (meaning actually <leader>fg here)
            { 'g', {
                { 'b', '<cmd>Telescope git_branches<cr>' },
                -- This will actually map <leader>fgc
                { 'c', '<cmd>Telescope git_commits<cr>' },
                { 's', '<cmd>Telescope git_status<cr>' },
            }},
        }},

        -- Lua functions can be right side values instead of key sequences
        { 'l', {
            { 'r', vim.lsp.buf.rename },
            { 's', vim.lsp.buf.signature_help },
            { 'h', vim.lsp.buf.hover },
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
