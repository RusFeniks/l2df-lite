local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local class = {
    component = {
        transform = core:require("class.component.transform"),
        text = core:require("class.component.text"),
    }
}

local text = core:require("class.gameobject"):extend()

    function text:init(_kwargs)
        _kwargs = _kwargs or {  }

        self:super(_kwargs)
        self:addComponent(class.component.transform, _kwargs)
        self:addComponent(class.component.text, _kwargs)
    end

return text
