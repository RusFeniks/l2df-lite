local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local behaviour = core:require("class.component"):extend()

    function behaviour:init()
        -- body
    end


    function behaviour:added(_gameobject, _kwargs)
        _kwargs = _kwargs or {  }
        local _storage = _gameobject.data[self]

        _storage.active = true
        _storage.events = { }

        for event, callback in pairs(_kwargs) do
            self:setAction(_gameobject, event, callback)
        end
    end

    function behaviour:setAction(_gameobject, event, callback)
        if type(callback) ~= "function" then return end
        local _storage = _gameobject.data[self]
        _storage.events[event] = callback
        self[event] = function ( self, _gameobject, ... )
            if not _storage.active then return end
            self:invoke( event, _gameobject, ... )
        end
    end

    function behaviour:invoke(_event, _gameobject, ...)
        local _storage = _gameobject.data[self]
        _gameobject.data[self].events[_event](_gameobject, ...)
    end



    function behaviour:toggle (_gameobject, _value)
        local _storage = _gameobject.data[self]
        if type(_value) == "boolean" then
            _storage.active = _value
            return
        end
        _storage.active = not _storage.active
    end



return behaviour
