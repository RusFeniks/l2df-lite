local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local repository = core:require("manager.repository")

local function appendState ( _state, _gameobject, _data )
    local _stateFunction = repository:get("state", _state[1] or nil)
    if type(_stateFunction) ~= "function" then return end
    _stateFunction( _gameobject, _data, _state )
end

local states = core:require("class.component"):extend()

    function states:added(_gameobject, _kwargs)
        _kwargs = _kwargs or { }
        local _data = _gameobject.data
        _data.states = {  }
        _data.constates = _kwargs.constates or { }
    end

    function states:update(_gameobject)
        local _data = _gameobject.data
        for _i = 1, #_data.constates do
            appendState(_data.constates[_i], _gameobject, _data)
        end
        for _i = 1, #_data.states do
            appendState(_data.states[_i], _gameobject, _data)
        end
        _data.states = {}
    end

return states
