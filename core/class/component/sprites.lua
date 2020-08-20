local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local manager = {
    render = core:require("manager.render"),
    resource = core:require("manager.resource")
}

local floor = math.floor

local sprites = core:require("class.component"):extend()

    sprites.unique = true

    --- Компонент sprites завязан на render менеджере. Его главная задача - подготавливать "объект" отрисовки и отправлять готовые данные в менеджер рендера.
    -- _kwargs таблица значений, используемых компонентом
    -- _kwargs.sprites таблица со списком ресурсов спрайтов вида { sprite, x, y, w, h }

    function sprites:added(_gameobject, _kwargs)
        local _data = _gameobject.data
        local _storage = _gameobject.data[self]

        _kwargs = _kwargs or { }

        _data.pic = _kwargs.pic or _data.pic or 1
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

        _data._facing = _data._facing or 1
        _data.facing = _data.facing or 1

        _storage.sprites = { }

        local _sprites = _kwargs.sprites or {  }
        local _position = 1
        for i = 1, #_sprites do
            if type(_sprites[i]) == "table" then
                local _s = _sprites[i]
                local _p = _position
                _s.file = _s.file or _s[1] or nil
                _s.x = _s.x or _s[2] or 1
                _s.y = _s.y or _s[3] or 1
                _s.w = _s.w or _s[4]
                _s.h = _s.h or _s[5]
                _s.ox = _s.ox or _s[6] or 0
                _s.oy = _s.oy or _s[7] or 0
                if _s.file then
                    manager.resource:load(_s.file)
                    manager.resource:loadASYNC( _s.file, function ( _resource )
                        log:info(_resource)
                        local _w, _h = _resource:getDimensions()
                        self:addSprites(_storage.sprites, _s.file, {
                            _s.x,
                            _s.y,
                            _s.w or (_w / _s.x),
                            _s.h or (_h / _s.y),
                            _w,
                            _h,
                            _s.ox,
                            _s.oy
                        }, _p)
                    end)
                end
                _position = _position + _s.x * _s.y
            else
                log:warn("sprites element is not a table")
            end
        end
    end

    function sprites:addSprites(_sprites, _file, _info, _start, _count)
        _count = _count or (_info[1] * _info[2])
        local _xo, _yo
        for i = 0, _count - 1 do
            _yo = floor(i / _info[1])
            _xo = i - _info[1] * (_yo)
            _sprites[_start + i] = {
                file = _file,
                quad = manager.render:addQuad(_info[3] * _xo + _info[7], _info[4] * _yo + _info[8], _info[3], _info[4], _info[5], _info[6])
            }
        end
    end

    function sprites:update(_gameobject, _input)
        _input = _input or {  }
        local _data = _gameobject.data
        if _data.pic < 1 then return end
        local _sprite = _data[self].sprites[_data.pic]
        if not (_sprite and (_input.layer or _data.layer)) then return end
        manager.render:draw({
            layer = _input.layer or _data.layer,
            resource = manager.resource:get(_sprite.file),
            sprite = _sprite.quad,
            x = _data._x + (_data.x * _data._facing),
            y = _data._y + _data.y,
            z = _data._z + _data.z,
            sx = _data._facing * _data.facing,
            sy = 1,
            ox = _data.centerx,
            oy = _data.centery,
        })
    end

    function sprites:updateBackground(_gameobject, _input)
        self:update(_gameobject, _input)
    end

return sprites
