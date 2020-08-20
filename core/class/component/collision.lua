local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local repository = core:require("manager.repository")

local sqrt = math.sqrt
local min = math.min
local max = math.max

local manager = {
    physics = core:require("manager.physics"),
    render = core:require("manager.render")
}

local collision = core:require("class.component"):extend()

    collision.unique = true

    function collision:added(_gameobject, _kwargs)
        _kwargs = _kwargs or {}
        local _data = _gameobject.data
        _data.itrs = { }
        _data.bdys = { }

        _data.facing = _data.facing or 1

        _data.xvelocity = _data.xvelocity or 0
        _data.yvelocity = _data.yvelocity or 0
        _data.zvelocity = _data.zvelocity or 0

        _data.centerx = _data.centerx or 0
        _data.centery = _data.centery or 0

        _data.x = _data.x or 0
        _data.y = _data.y or 0
        _data.z = _data.z or 0

        _data._x = _data._x or 0
        _data._y = _data._y or 0
        _data._z = _data._z or 0

        _kwargs.itrs = _kwargs.itrs or { }
        _kwargs.bdys = _kwargs.bdys or { }
        
        local _itr, _bdy
        for _i = 1, #_kwargs.itrs do
            _itr = _kwargs.itrs[_i]
            _data.itrs[#_data.itrs + 1] = {
                kind = _itr.kind or nil,
                x = _itr.x or 0,
                y = _itr.y or 0,
                z = _itr.z or 0,
                w = _itr.w or 0,
                h = _itr.h or 0,
                d = _itr.d or 5,
            }
        end
        for _i = 1, #_kwargs.bdys do
            _bdy = _kwargs.bdys[_i]
            _data.bdys[#_data.bdys + 1] = {
                x = _bdy.x or 0,
                y = _bdy.y or 0,
                z = _bdy.z or 0,
                w = _bdy.w or 0,
                h = _bdy.h or 0,
                d = _bdy.d or 5,
            }
        end
    end

    local _x1, _x2, _y1, _y2, _z1, _z2
    local function collider( _gameobject, _col, _fun )

        local _data = _gameobject.data

        --_r.r = _col.r or _col.w * _col.h * _col.d > 0 and sqrt(_col.w ^ 2 + _col.h ^ 2 + _col.d ^ 2) / 2 or 0

        _x1 = _data._x + _data.x + (((_col.x or 0) - _data.centerx) * _data.facing)
        _x2 = _x1 + ((_col.w or 0) * _data.facing)

        _y1 = _data._y + _data.y + (_col.y or 0) - _data.centery
        _y2 = _y1 + (_col.h or 0)

        _z1 = _data._z + _data.z + (_col.z or 0)
        _z2 = _z1 + (_col.d or 0)

        local _collider = {
            kind = _col.kind or 0,
            owner = _gameobject,
            data = _data,
            col = _col,
            action = _fun,
            w = _col.w or 0,
            h = _col.h or 0,
            z = _col.z or 0,
            x1 = min(_x1, _x1 + _data.xvelocity, _x2, _x2 + _data.xvelocity),
            x2 = max(_x1, _x1 + _data.xvelocity, _x2, _x2 + _data.xvelocity),
            y1 = min(_y1, _y1 + _data.yvelocity, _y2, _y2 + _data.yvelocity),
            y2 = max(_y1, _y1 + _data.yvelocity, _y2, _y2 + _data.yvelocity),
            z1 = min(_z1, _z1 + _data.zvelocity, _z2, _z2 + _data.zvelocity),
            z2 = max(_z1, _z1 + _data.zvelocity, _z2, _z2 + _data.zvelocity),
        }

        if DEBUG then
            manager.render:draw({
            layer = "debug",
            fill = "line",
            x1 = _collider.x1,
            x2 = _collider.x2,
            y1 = _collider.y1,
            y2 = _collider.y2,
            z = 1,
        }) end

        return _collider
    end

    function collision:update(_gameobject)
        local _data = _gameobject.data
        for _i = 1, #_data.bdys do
            manager.physics:addBDY(collider(_gameobject, _data.bdys[_i]))
        end
        for _i = 1, #_data.itrs do
            local _itr = _data.itrs[_i]
            local _kindFunction = repository:get("kind", _itr.kind or nil)
            if type(_kindFunction) == "function" then
                manager.physics:addITR(collider(_gameobject, _itr, _kindFunction))
            end
        end
    end

    function collision.collide( _itr, _bdy )
        -- body
    end

return collision
