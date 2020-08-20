local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local class = {
    component = {
        transform = core:require("class.component.transform"),
        sprites = core:require("class.component.sprites"),
        collision = core:require("class.component.collision"),
        frames = core:require("class.component.frames"),
        states = core:require("class.component.states")
    }
}

local button = core:require("class.gameobject"):extend()

    function button:init(_kwargs)
        _kwargs = _kwargs or {  }

        self:super(_kwargs)
        self:addComponent(class.component.sprites, _kwargs)
        self:addComponent(class.component.transform, _kwargs)
        self:addComponent(class.component.collision, _kwargs)
        self:addComponent(class.component.frames, _kwargs)
        self:addComponent(class.component.states, _kwargs)
    end

    function button:clicked()
        --body
    end



return button
