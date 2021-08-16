# nest.nvim

Neovim utility plugin to define keymaps in concise, readable, cascading lists
and trees

- Modular, maintainable pure Lua way to define keymaps
- Written in a single file of ~100 lines
- Supports mapping keys to Lua functions
- Only supports `neovim`

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 'LionC/nest.nvim' }
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'LionC/nest.nvim'
```

### Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('LionC/nest.nvim')
```

## Quickstart Guide

The `nest` Lua module exposes an `applyKeymaps` function that can be called
any number of times with a list of (nested) keymaps to be set.

Keymaps will default to `normal` mode, `noremap` and `silent` unless
overwritten.  Overrides are inherited by nested keymaps.

```lua
local nest = require('nest')

function helloWorld() vim.cmd [[echo "Hello World!"]] end

nest.applyKeymaps {
    -- Remove silent from ; : mapping, so that : shows up in command mode
    { ';', ':' , options = { silent = false } },
    { ':', ';' },

    -- Lua functions can be right side values instead of key sequences
    { 'Q', helloWorld },

    -- Prefix  every nested keymap with <leader>
    { '<leader>', {
        -- Prefix every nested keymap with f (meaning actually <leader>f here)
        { 'f', {
            { 'f', '<Cmd>Telescope find_files<CR>' },
            -- This will actually map <leader>fl
            { 'l', '<Cmd>Telescope live_grep<CR>' },
            -- Prefix every nested keymap with g (meaning actually <leader>fg here)
            { 'g', {
                { 'b', '<Cmd>Telescope git_branches<CR>' },
                -- This will actually map <leader>fgc
                { 'c', '<Cmd>Telescope git_commits<CR>' },
                { 's', '<Cmd>Telescope git_status<CR>' },
            }},
        }},

        { 'l', {
            { 'c', '<Cmd>lua vim.lsp.buf.code_actions()<CR>' },
            { 'r', '<Cmd>lua vim.lsp.buf.rename()<CR>' },
            { 's', '<Cmd>lua vim.lsp.buf.signature_help()<CR>' },
            { 'h', '<Cmd>lua vim.lsp.buf.hover()<CR>' },
        }},
    }},

    -- Use insert mode for all nested keymaps
    { mode = 'i', {
        { 'jk', '<Esc>' },

        -- Set <expr> option for all nested keymaps
        { options = { expr = true }, {
            { "<CR>",       "compe#confirm('<CR>')" },
            -- This is equivalent to viml `inoremap <C-Space> <expr>compe#complete()`
            { "<C-Space>",  "compe#complete()" },
        }},

        { '<C-', {
            { 'h>', '<left>' },
            { 'l>', '<right>' },
            { 'o>', '<Esc>o' },
        }},
    }},
}
```

The passed `table` can be understood as a tree, with prefixes and config fields
cascading down to all children. This makes it not only very readable and groupable,
but also eases refactoring and modularization. Because `nest`-keymapConfigs are just
simple Lua values, they can be defined in their own files, passed around, plugged
into different prefixes or options etc.

## Advanced Usage

### Change defaults

You can change the defaults used by `applyKeymaps`:

```lua
local nest = require('nest')

nest.defaults.options = {
    noremap = false,
}
```

Defaults start out as

```lua
{
    mode = 'n',
    prefix = '',
    options = {
        noremap = true,
        silent = true,
    },
}
```

## Reference

### `nest.applyKeymaps`

Expects a `keymapConfig`, which is a table with at least two indexed properties
in one of the following four shapes:

#### Keymap

```lua
{ 'inputsequence', 'outputsequence' }
```

Sets a keymap, mapping the input sequence to the output sequence similiar to
the VimL `:*map` commands.

#### Lua Function Keymap

```lua
{ 'inputsequence', someLuaFunction }
```

Sets a keymap, mapping the input sequence to call the given lua function.

#### Config Subtree

```lua
{ 'inputprefix', keymapConfig }
```

Append the inputprefix to the current prefix and applies the given
`keymapConfig`s with the new prefix.

#### Config List

```lua
{
    keymapConfig,
    keymapConfig,
    keymapConfig
    -- ...
}
```

Applies all given `keymapConfig`s.

Each `keymapConfig` can also have any of the following fields, which will cascade
to all containing sub-`keymapConfig`s:

#### `mode`

Sets the Vim mode for keymaps contained in the `keymapConfig`.

Accepts all values `nvim_set_keymap`s `mode` parameter accepts. See `:help
nvim_set_keymap`

#### `options`

Sets mapping options like `<buffer>`, `<silent>` etc. for keymaps contained in
the `keymapConfig`.

**Note that `options` gets merged** into the options in its context. This means
that you only have to pass the `options` you want to change instead of replacing
the whole object.

Accepts all values `nvim_set_keymap`s `options` parameter accepts. See `:help
nvim_set_keymap`.

### `nest.defaults`

`table` containing the defaults applied to keymaps. Can be modified or overwritten.

Has the same named fields as `keymapConfig`, with an additional field:

#### `prefix`

Sets a `string` prefix to be applied to all keymap inputs.

## Planned Features

- 1.1
    - add optional `description`s to keymaps
    - allow looking up custom keymaps via some command
    - optional telescope integration
