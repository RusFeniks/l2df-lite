local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local manager = {
    render = core:require("manager.render"),
    font = core:require("manager.font")
}

local floor = math.floor



local text = core:require("class.component"):extend()

    function text:added(_gameobject, _kwargs)
        local _data = _gameobject.data
        local _storage = _gameobject.data[self]

        _kwargs = _kwargs or { }

        _data.index = _data.index or 0
        _data.layer = _kwargs.layer or nil

        _data.x = _data.x or 0
        _data.y = _data.y or 0
        _data.z = _data.z or 0

        _data._x = _data._x or 0
        _data._y = _data._y or 0
        _data._z = _data._z or 0

        _data.centerx = _data.centerx or 0
        _data.centery = _data.centery or 0

        _storage.text = _kwargs.text and tostring(_kwargs.text) or nil
        _storage.font = _kwargs.font or nil
        _storage.align = _kwargs.align or "left"
        _storage.limit = _kwargs.width
    end

    function text:update(_gameobject, _input)

        _input = _input or {  }
        local _data = _gameobject.data
        local _storage = _gameobject.data[self]

        if not _storage.text then return end
        manager.render:draw({
            layer = _input.layer or _data.layer,
            text = _storage.text,
            font = manager.font:get(_storage.font),
            limit = _storage.limit,
            align = _storage.align,
            x = _data._x + _data.x,
            y = _data._y + _data.y,
            z = _data._z + _data.z,
            ox = _data.centerx,
            oy = _data.centery,
            color = { 1, 1, 1, 1 }
        })
    end

    function text:updateBackground(_gameobject, _input)
        self:update(_gameobject, _input)
    end

return text
