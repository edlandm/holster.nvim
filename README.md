# holster.nvim

This is a plugin to make sure that you always have the right tool for the job
just a quick-draw away. It allows you to configure a list of commands to be
able to run via `vim.ui.select`. It includes custom pickers for
[Snacks.picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md).

The commands are configured per directory.

## Inspiration
I write project-specific commands for building, compiling, generating
documentation, etc. I was keeping them in my notes file ([Neorg](https://github.com/nvim-neorg/neorg), if anyone's
wondering) and had written a simple code-runner to execute code-blocks, but
I was getting tired of needing to switch to the notes-file and navigating to
the correct code-block everytime I needed to run one of the commands. I wanted
a tool-belt so that I could keep all of those commands with me without having
to move away from what I was working on.

## Install

### lazy.nvim
```lua
return {
  'edlandm/holster.nvim',
  lazy = false,
  opts = {},
  main = 'holster'
}
```

## Config

### Default Options
```lua
---@class Holster.opts
---@field command_file path name of the file in the current directory for Holster to look for

opts = {
    command_file = '.holster.nvim.lua',
}
```

### Defining Commands

Holster checks the current directory for a file matching `opts.command_file`
(default: `.holster.nvim.lua`). This file is expected to return a table
containing a list of command specifications.

Example:
```lua
return {
    commands = {
        {
            name = 'hello world',
            desc = "echo \"hello world\" using neovim's builtin echo command",
            cmd = 'echo "hello world"',
        },
        {
            name = 'ola lua',
            desc = "echo \"ola lua\" using a lua's print function",
            cmd = function()
                print('ola lua')
            end,
        },
        {
            name = 'shell example',
            desc = "write a message to ./holster-example.txt using a bash shell",
            shell = 'echo "this is Ground Control to Major Tom" > holster-example.txt',
            after = 'read holster-example.txt'
        },
    },
}
```

### snacks.picker

If using lazy.nvim, add this to your snacks.nvim config:
```lua
{
    'folke/snacks.nvim',
    dependencies = {
        'edlandm/holster.nvim'
    },
    opts = {
        picker = {
            config = function(opts, defaults)
                Snacks.picker.holster_commands = require('holster').pickers.commands
            end,
        },
    },
    keys = {
        -- change these mappings to whatever you want; this is just an example
        { '<leader>hc', '<cmd>lua Snacks.picker.holster_commands()<cr>', desc = 'Pick Holster Commands' },
    },
}
```
