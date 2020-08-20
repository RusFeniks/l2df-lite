local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local manager = {}
local class = {}

local stack = {
    { x = 0, y = 0, z = 0, facing = 1 }
}


--- Я тут на хую ничего вертеть не собираюсь, поэтому только по трём осям пока что
--- Возможно в полной версии движка стоит зашить Transform как должное в сущность. Т.е. чтобы сущность не могла быть создана без компонента Transform
--- Мейби даже функционал зашить не в компонент, а непосредственно в сущность саму... надо думать и пробовать

local transform = core:require("class.component"):extend()

    transform.unique = true

    function transform:added(_gameobject, _kwargs)
        local _data = _gameobject.data
        _data._x = _data._x or 0
        _data._y = _data._y or 0
        _data._z = _data._z or 0
        _data.facing = _data.facing or 1
    end

    function transform:push(_gameobject)
        local _data = _gameobject.data
        local _stack = stack[#stack]
        stack[#stack + 1] = {
            x = _data.x + _stack.x,
            y = _data.y + _stack.y,
            z = _data.z + _stack.z,
            facing = _data.facing * _stack.facing,
        }
    end

    function transform:pop()
        stack[#stack] = nil
    end

    function transform:update(_gameobject)
        local _data = _gameobject.data
        local _stack = stack[#stack]
        _data._x = _stack.x
        _data._y = _stack.y
        _data._z = _stack.z
        _data._facing = _stack.facing
    end

return transform
