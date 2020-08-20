local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local parser = {}

    local function getValue(_val)
        _val = _val:gsub("\"", "")
        if _val == "true" then return true end
        if _val == "false" then return false end
        return tonumber(_val) or _val
    end

    local function special ( _string )
        return _string and _string:match("[<%[:]")
    end

    local function var( _string )
        return _string and _string:match("^([%a][%w_]*):$")
    end

    local function open_table ( _string )
        if not _string then return end
        local _option1 = _string:match("^%<([%a][%w_:]*)%>$")
        local _option2 = _string:match("^%[([%a][%w_:]*)%]$")
        return _option1 or _option2, _option1 and true or false
    end

    local function close_table ( _string )
        if not _string then return end
        local _option1 = _string:match("^%</([%a][%w_:]*)%>$")
        local _option2 = _string:match("^%[/([%a][%w_:]*)%]$")
        return _option1 or _option2, _option1 and true or false
    end

    local function isString( _string )
        return _string:match("^[\"]([%a%w_!,%.]*)"), _string:match("([%a%w_!,%.]*)[\"]$")
    end

    local function splitTableTag(_string)
        local _split = _string:find(":")
        if _split then
            return _string:sub(0, _split - 1), _string:sub(_split + 1)
        end
        return _string
    end

    local function parse( _elems )
        local _result = {}
        local _i = 1
        local _name
        local _value
        local _isMassive
        local _deep
        local _concat

        while _i <= #_elems do

            -- ПЕРЕМЕННАЯ
            if var( _elems[_i] ) then

                _name = var(_elems[_i])
                _i = _i + 1
                _value = {}

                _concat = false
                while _elems[_i] and not special(_elems[_i]) do
                    local _o, _c = isString(_elems[_i])
                    if _concat then
                        _value[#_value] = tostring(_value[#_value]) .. " " .. tostring(getValue(_elems[_i]))
                    else
                        _value[#_value + 1] = getValue(_elems[_i])
                    end
                    if _o then _concat = true end
                    if _c then _concat = false end
                    _i = _i + 1
                end

                _result[_name] = _value
                if #_value == 1 then
                    _result[_name] = _value[1]
                end

            -- ТАБЛИЦА
            elseif open_table ( _elems[_i] ) then
                _name, _isMassive = open_table ( _elems[_i] )
                local _option
                _name, _option = splitTableTag(_name)
                _name = _isMassive and _name .. "s" or _name
                _i = _i + 1

                _value = {}
                _deep = 1

                while _elems[_i] and _deep > 0 do
                    if (close_table ( _elems[_i] )) then
                        _deep = _deep - 1
                    elseif (open_table (_elems[_i] )) then
                        _deep = _deep + 1
                    end
                    _value[#_value + 1] = _elems[_i]
                    _i = _i + 1
                end
                _value[#_value] = nil

                _value = parse(_value)
                _value.__option = _option

                _result[_name] = _result[_name] or { }
                if _isMassive then
                    _result[_name][#_result[_name] + 1] = _value
                else
                    _result[_name] = _value
                end


            -- ЗНАЧЕНИЕ БЕЗ ИНДЕКСА
            elseif not special(_elems[_i]) then
                _value = getValue(_elems[_i])
                _result[#_result + 1] = _value
                _i = _i + 1

            --- ИНАЧЕ
            else
                _i = _i + 1
            end
        end
        return _result -- возвращаем результат
    end

    function parser:init(  )
        log:success("Parser module initialized!")
    end

    function parser:parse( _string )
        local _elems = {}
        if not _string then return _elems end
        for _elem in _string:gmatch("(%S+)") do
            _elems[#_elems + 1] = _elem
        end
        return parse(_elems)
    end

    function parser:assembly( _table, _offset )
        
        local _result = ""
        local _intermediateResult
        
        local _space = ""
        _offset = _offset or 0
        for i = 1, _offset do
            _space = _space .. "    "
        end

        for _key, _val in pairs(_table) do
            _intermediateResult = ""
            if type(_val) == "table" then
                _intermediateResult = _space .. "[" .. tostring(_key) .. "]\n"
                .. self:assembly(_val, _offset + 1)
                .. _space .. "[/" .. tostring(_key) .. "]"
            else
                _val = type(_val) == "string" and "\"" .. _val .. "\"" or _val
                _intermediateResult = _space .. tostring(_key) .. ": " .. tostring(_val)
            end
            _result = _result .. _intermediateResult .. "\n"
        end
        return _result
    end

return parser
