local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local max = math.max
local min = math.min
local floor = math.floor
local ceil = math.ceil
local limit = help.limit



local physics = {}

    local movable = {}
    local colworldStack = {} -- миры, для которых будет произвоидится просчет коллизий

    function physics:init( ... )
        core:hook("update", function ( ... )
            self:update(...)
        end)
        log:success("Physic manager initialized!")
    end

    ---------------------------
    --
    --        КОЛЛИЗИИ
    --
    ---------------------------

    local width = 16
    local space = {  }
    local itrs = {  }

    local spacemap = { }
    local usedspace = { }
    

    local function getIndex( _col, _w )
        return floor(_col.x1 / _w), ceil(_col.x2 / _w)
    end

    local function checkCollisions(_itr)
        local ix1, ix2 = getIndex(_itr, width)
        while ix1 < ix2 do
            if space[ix1] then
                for _b = 1, #space[ix1] do
                    local _bdy = space[ix1][_b]
                    if _bdy.data ~= _itr.data and _bdy.last ~= _itr and (_bdy.kind == 0 or _itr.kind == 0 or _bdy.kind == _itr.kind) then
                        if  (_itr.x1 <= _bdy.x2) and (_itr.x2 >= _bdy.x1)
                            and (_itr.y1 <= _bdy.y2) and (_itr.y2 >= _bdy.y1)
                            and (_itr.z1 <= _bdy.z1) and (_itr.z2 >= _bdy.z1) then
                                _itr.action(_itr, _bdy)
                            end
                        _bdy.last = _itr
                    end
                end
            end
            ix1 = ix1 + 1
        end
    end

    local function collide()
        local _space = space
        local ix1, ix2, _itr, _bdy
        for _i = 1, #itrs do
            _itr = itrs[_i]
            checkCollisions(_itr)
        end
        space = {  }
        itrs = {  }
    end

    function physics:addBDY(_bdy)
        local ix1, ix2 = getIndex(_bdy, width)
        _bdy.last = {}
        while ix1 < ix2 do
            space[ix1] = space[ix1] or { }
            space[ix1][#space[ix1] + 1] = _bdy
            ix1 = ix1 + 1
        end
    end

    function physics:addITR(_itr)
        itrs[#itrs + 1] = _itr
    end



    ---------------------------
    --
    --       ПЕРЕМЕЩЕНИЕ
    --
    ---------------------------

    function physics:move( _gameobject, _world )
        if not (_gameobject and _world) then return end
        movable[#movable + 1] = { _gameobject, _world }
    end

    local function move( _gameobject, _world )
        local _data = _gameobject.data

        _data.x = _data.x + (_data.dx * _data.facing) + _data.xvelocity
        _data.y = _data.y + _data.dy + _data.yvelocity
        _data.z = _data.z + _data.dz + _data.zvelocity

        local _borders = _world.borders

        _data.x = _borders.x1 and max(_borders.x1, _data.x) or _data.x
        _data.x = _borders.x2 and min(_borders.x2, _data.x) or _data.x

        _data.xvelocity = _borders.x1 and _data.x <= _borders.x1 and 0 or _data.xvelocity
        _data.xvelocity = _borders.x2 and _data.x >= _borders.x2 and 0 or _data.xvelocity

        _data.y = _borders.y1 and max(_borders.y1, _data.y) or _data.y
        _data.y = _borders.y2 and min(_borders.y2, _data.y) or _data.y

        _data.yvelocity = _borders.y1 and _data.y <= _borders.y1 and 0 or _data.yvelocity
        _data.yvelocity = _borders.y2 and _data.y >= _borders.y2 and 0 or _data.yvelocity

        _data.z = _borders.z1 and max(_borders.z1, _data.z) or _data.z
        _data.z = _borders.z2 and min(_borders.z2, _data.z) or _data.z

        _data.zvelocity = _borders.z1 and _data.z <= _borders.z1 and 0 or _data.zvelocity
        _data.zvelocity = _borders.z2 and _data.z >= _borders.z2 and 0 or _data.zvelocity

        _data.dx, _data.dy, _data.dz = 0, 0, 0
    end

    ---------------------------
    --
    --     ВЫЧИСЛЕНИЕ
    --
    ---------------------------

    function physics:update( ... )
        local _gameobject, _world
        collide()
        for _i = 1, #movable do
            move( movable[_i][1], movable[_i][2] )
        end
        movable = {}
    end

return physics
