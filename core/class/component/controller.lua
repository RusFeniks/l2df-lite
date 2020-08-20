local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local manager = {
    control = core:require("manager.control")
}

local controller = core:require("class.component"):extend()

    controller.unique = false

    function controller:added(_gameobject, _kwargs)
        _kwargs = _kwargs or {  }
        local _data = _gameobject.data
        local _storage = _data[self]

        _data.key = {}
        _storage.id = 0

        function self:set(_id)
            _storage.id = _id
        end

        self:set(_kwargs.controller or 0)
    end

    function controller:update(_gameobject)
        local _data = _gameobject.data
        local _storage = _data[self]
        _data.key = manager.control:getKeys(_storage.id)
    end

return controller
