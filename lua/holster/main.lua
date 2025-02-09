package.loaded['holster'] = {}
local M = package.loaded['holster']
M.pickers = {}

---@type Holster.opts
M.opts = {
  command_file = '.holster.nvim.lua',
}

---execute a vim command or lua function
---@param cmd string | fun() command to be run
local function run_vim_or_lua(cmd)
  local _type = type(cmd)
  if _type == 'string' then
    vim.cmd(cmd)
  elseif _type == 'function' then
    cmd()
  else
    error(('%s unsupported type: %s'):format('run_vim_or_lua', _type))
  end
end

local function run_command(item)
  assert(item.cmd or item.shell, 'invalid item: must have either cmd or shell property')
  assert(not (item.cmd and item.shell), 'invalid item: cannot have both cmd and shell properties')
  if item.cmd then
    run_vim_or_lua(item.cmd)
    if item.after then
      run_vim_or_lua(item.after)
    end
    return true
  end

  local c = {}
  local env = item.env
  if env then
    table.insert(c, 'env')
    for k, v in pairs(env) do
      table.insert(c, ('%s=%s'):format(k, v))
    end
  end

  table.insert(c, 'bash')

  local lines = vim.split(item.shell, '\n')
  vim.fn.system(c, lines)
  if item.after then
    run_vim_or_lua(item.after)
  end

  return true
end

---map a command to a Snacks picker item
---@param cmd Holster.Command
---@return Holster.snacks.picker.Item
local function picker_command_to_item(cmd)
  local ft = 'sh'
  if cmd.cmd then
    ft = type(cmd.cmd) == 'string' and 'vim' or 'lua'
  end

  local cmt = '#'
  if ft == 'lua' then
    cmt = '--'
  elseif ft == 'vim' then
    cmt = '"'
  end

  local preview_desc = ('%s %s'):format(cmt, cmd.name)
  if cmd.desc then
    preview_desc = table.concat(
      vim.tbl_map(
        function(line) return ('%s %s'):format(cmt, line) end,
        vim.split(cmd.desc, '\n')),
      '\n')
  end

  local preview_cmd = 'lua <function>'
  if (ft == 'vim' or ft == 'sh') then
    local command = cmd.cmd or vim.trim(cmd.shell)
    ---@cast command string

    preview_cmd = table.concat(
      vim.tbl_map(
        function(line) return vim.fn.trim(line) end,
        vim.split(command, '\n', {trimempty=true})),
      '\n')
  end

  return {
    text = cmd.name,
    preview = {
      text = table.concat({ preview_desc, preview_cmd }, '\n'),
      ft = ft,
    },
    env   = cmd.env,
    cmd   = cmd.cmd,
    shell = cmd.shell,
    after = cmd.after,
  }
end

local function picker_command_format(item)
  return {
    { tostring(item.idx) .. '. ', 'SnacksPickerBufNr' },
    { item.text, 'SnacksPickerFile' },
  }
end

local function picker_command_run(picker, item)
  picker:close()
  if item then
    run_command(item)
  end
end

---list commands defined in M.command_file
function M.pickers.commands()
  local success, picker = pcall(require, 'snacks.picker')
  assert(success, 'holster.pickers require snacks.picker to be enabled')

  local file = M.opts.command_file

  -- TODO: if the file doesn't exist (or no commands present),
  -- still open the picker but display a message to press `<c-e>` to create
  -- and edit `file`
  if not vim.uv.fs_stat(file) then
    print(file .. ' not found in current directory')
    return
  end

  local chunk, err = loadfile(file)
  assert(chunk, ('failed to load %s as lua: %s'):format(file, err))

  local obj = chunk()
  if not obj then
    print(('%s did not return anything'):format(file))
    return
  end

  if not obj.commands then
    print(('%s did not return any commands'):format(file))
    return
  end

  ---@type Holster.Command[]
  local cmds = obj.commands

  picker.pick {
    source = 'Holster Commands',
    layout = 'vscode',
    actions = {
      edit = {
        name = 'Edit ' .. file,
        action = function(self)
          self:close()
          vim.cmd({ cmd = 'edit', args = { file } })
        end
      },
    },
    confirm = picker_command_run,
    items = vim.tbl_map(picker_command_to_item, cmds),
    preview = 'preview',
    format = picker_command_format,
    win = {
      input = {
        keys = {
          ['<C-e>'] = { 'edit', mode = { 'n', 'i' } },
        },
      },
    },
  }
end

---setup the plugin with configuration options
---@param opts Holster.opts
---@return Holster
function M.setup(opts)
  M.opts = vim.tbl_deep_extend('keep', opts or {}, M.opts)
  return M
end

return M
