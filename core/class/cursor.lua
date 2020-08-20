local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local class = {
    component = {
        collision = core:require("class.component.collision"),
        behaviour = core:require("class.component.behaviour"),
        states = core:require("class.component.states")
    }
}

local manager = {
    render = core:require("manager.render")
}

local cursor = core:require("class.gameobject"):extend()

    function cursor:init()
        local _kwargs = {
            itrs = {
                { kind = "mouse", x = 1, y = 1, w = 5, h = 5, z = 1, d = 10 }
            }
        }

        self:super(_kwargs)
        self:addComponent(class.component.collision, _kwargs)
        self:addComponent(class.component.states, _kwargs)
        self:addComponent(class.component.behaviour, {
            update = self.update
        })
    end

    function cursor:update()
        local _scaleX, _scaleY, ox, oy = manager.render:getScaleInfo()
        self.data.x = (love.mouse.getX() - ox) / _scaleX
        self.data.y = (love.mouse.getY() - oy) / _scaleY
    end



return cursor
