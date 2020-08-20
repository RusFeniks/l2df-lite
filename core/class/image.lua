local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local class = {
    component = {
        transform = core:require("class.component.transform"),
        sprites = core:require("class.component.sprites")
    }
}

local image = core:require("class.gameobject"):extend()

    function image:init(_kwargs)
        _kwargs = _kwargs or {  }
        self:super(_kwargs)
        self:addComponent(class.component.sprites:new(), _kwargs)
        self:addComponent(class.component.transform:new(), _kwargs)
    end

return image
