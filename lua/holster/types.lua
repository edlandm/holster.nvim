---@alias path string path to a file or directory

---@class Holster.opts
---@field command_file path

---@class Holster
---@field opts Holster.opts
---@field picker fun(self:Holster)

---@alias Holster.Command.Nvim.CmdOrFun string | fun()

---@class Holster.Command.Base
---@field name string
---@field desc? string
---@field after? Holster.Command.Nvim.CmdOrFun

---@class Holster.Command.Nvim:Holster.Command.Base
---@field cmd Holster.Command.Nvim.CmdOrFun

---@class Holster.Command.Shell:Holster.Command.Base
---@field env? { [string]: string }
---@field shell string

---@alias Holster.Command Holster.Command.Nvim | Holster.Command.Shell

---@class Holster.Command.spec
---@field commands Holster.Command[]

---@class Holster.snacks.picker.Item:snacks.picker.finder.Item
---@field env? { [string]: string }
---@field cmd? Holster.Command.Nvim.CmdOrFun
---@field after? Holster.Command.Nvim.CmdOrFun
---@field shell? string
