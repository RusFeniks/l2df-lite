local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local class = {
    component = {
        physics = core:require("class.component.physics")
    }
}

local world = core:require("class.component"):extend()

    world.unique = true

    function world:added(_gameobject, _kwargs)
        _kwargs = _kwargs or {  }
        local _storage = _gameobject.data[self]

        _storage.gravity = _kwargs.gravity or 0
        _storage.resistance = _kwargs.resistance or 1
        _storage.borders = {
            x1 = _kwargs.x1,
            x2 = _kwargs.x2,
            y1 = _kwargs.y1,
            y2 = _kwargs.y2,
            z1 = _kwargs.z1,
            z2 = _kwargs.z2,
        }
    end

    function world:update(_gameobject)
        local _storage = _gameobject.data[self]
        _gameobject:getNodes(function ( _node )
            _node:componentsEvent("add", class.component.physics, _storage)
        end)
    end

return world
