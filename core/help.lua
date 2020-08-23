local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local floor = math.floor
local ceil = math.ceil
local abs = math.abs

local help = {}

    function help:init(  )
        log:success("Help module initialized!")
    end

    --[[ Эта функция должна умереть!
    function help.hook( _function, _callback )
        local _old_function = _function or function (  ) end
        _function = function ( ... )
            _callback(...)
            _old_function(...)
        end
        return _function
    end]]

    ---Проверяет, что объект является наследником класса
    ---@param _object table объект
    ---@param _class table класс
    ---@return boolean
    function help.class(_object, _class)
        return type(_object) == "table" and _object.isInstanceOf and _object:isInstanceOf(_class)
    end

    ---Создает копию таблицы, копируя все элементы, включая подтаблицы
    ---@param _input table таблица, которая будет скопирована
    ---@param _output table таблица в которую могут быть дописаны данные копируемой таблицы
    ---@param _seen any сохраненная метатаблица для избежания рекурсивной зацикленности
    ---@return table скопированная таблица
    function help.cloneTable(_input, _output, _seen)

        if type(_input) ~= 'table' then return _input end
        if _seen and _seen[_input] then return _seen[_input] end

        local s = _seen or {}
        local _res = _output or {}
        s[_input] = _res
        for k, v in pairs(_input) do _res[help.cloneTable(k, _res, s)] = help.cloneTable(v, _res, s) end
        return setmetatable(_res, getmetatable(_input))
    end


    function help.getFileExtension(url)
        return url:match("^.+(%..+)$")
    end


    function help.dump(_i, _p)
        _p = _p or ""
        local _s = tostring(_i)
        if type(_i) == "table" then
            for _k, _v in pairs(_i) do
                _s = _s .. "\n" .. tostring(_p) .. "[" .. _k .. "] " .. help.dump(_v, tostring(_p) .. "   ")
            end
        end
        return _s
    end

    function help.round(_n, _p)
        _p = 10 ^ (_p or 0)
        return _n > 0.5 and (floor(_n * _p) / _p) or _n < 0.5 and (ceil(_n * _p) / _p) or 0
    end

    function help.limit( _n, _l, _r )
        return (abs(_n) < _l and (_r or 0)) or _n
    end

    function help.convertColor( color )
        return color / 255
    end

return help
