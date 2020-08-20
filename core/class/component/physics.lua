local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local limit = help.limit
local _LIMIT_ = 0.1

local manager = {
    physics = core:require("manager.physics")
}

local physics = core:require("class.component"):extend()

    physics.unique = true

    function physics:added(_gameobject, _kwargs)
        _kwargs = _kwargs or {  }
        local _data = _gameobject.data

        _data.gravity = _kwargs.gravity or true
        _data.static = _kwargs.static or false

        _data.weight = _kwargs.weight or 1
        _data.rough = _kwargs.rough or 1

        _data.x = _data.x or 0
        _data.y = _data.y or 0
        _data.z = _data.z or 0

        _data.dvx = _data.dvx or 0
        _data.dvy = _data.dvy or 0
        _data.dvz = _data.dvz or 0

        _data.dsx = _data.dsx or 0
        _data.dsy = _data.dsy or 0
        _data.dsz = _data.dsz or 0

        _data.xvelocity = _data.xvelocity or 0
        _data.yvelocity = _data.yvelocity or 0
        _data.zvelocity = _data.zvelocity or 0

        _data.dx = _data.dx or 0
        _data.dy = _data.dy or 0
        _data.dz = _data.dz or 0

        _data.facing = _data.facing or 1
    end

    function physics:add( _gameobject, _world )
        local _data = _gameobject.data
        if _data.static then return end
        if (_data.dx + _data.xvelocity + _data.dvx + _data.dsx
            + _data.dy + _data.yvelocity + _data.dvy + _data.dsy
            + _data.dz + _data.zvelocity + _data.dvz + _data.dsz) == 0
            and not _data.gravity then return end

        _data.xvelocity = _data.dvx ~= 0 and (_data.dvx * _data.facing)
            or _data.dsx ~= 0 and _data.xvelocity + (_data.dsx * _data.facing)
            or limit (_data.xvelocity - _data.xvelocity * (_world.resistance * _data.rough), _LIMIT_, 0)

        _data.zvelocity = _data.dvz ~= 0 and _data.dvz
            or _data.dsz ~= 0 and _data.zvelocity + _data.dsz
            or limit (_data.zvelocity - _data.zvelocity * _world.resistance, _LIMIT_, 0)

        _data.yvelocity = _data.dvy ~= 0 and _data.dvy
            or _data.dsy ~= 0 and _data.yvelocity + _data.dsy
            or _data.gravity and _world.gravity * _data.weight > 0 and _data.yvelocity + (_world.gravity * _data.weight)
            or limit (_data.yvelocity - _data.yvelocity * _world.resistance, _LIMIT_, 0)

        _data.dvx, _data.dvy, _data.dvz = 0, 0, 0
        _data.dsx, _data.dsy, _data.dsz = 0, 0, 0

        manager.physics:move(_gameobject, _world)
    end

return physics
