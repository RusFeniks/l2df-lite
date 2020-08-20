local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local parser = core:require("parser")
local help = core:require("help")

local settingsData = {}

local settings = {}

    function settings:init(_kwargs)
        core.getSettings = function ( self, _key, _default )
            return settings:get(_key, _default)
        end
        core.setSettings = function ( self, _key, _value )
            return settings:set(_key, _value)
        end
        self.file = _kwargs.settingsFile
        settings:loadFromFile(self.file)
        log:success("Settings manager initialized!")
    end

    function settings:set(_key, _value)
        local _result = settingsData
        local _lastKey
        for _chunk in _key:gmatch("([^.]+)") do
            _result = _lastKey and _result[_lastKey] or _result
            _lastKey = _chunk
        end
        _result[_lastKey] = _value
    end

    function settings:get(_key, _default)
        local result = settingsData
        for _chunk in _key:gmatch("([^.]+)") do
            result = result[_chunk]
        end
        if result == nil then result = _default end
        log:info(_key, result, type(result))
        return result
    end

    function settings:loadFromFile(_file)
        local file = io.open (_file or self.file, "r+")
        if not file then
            log:warn("- Settings file not exist")
        return end
        settingsData = parser:parse(file:read("*a"))
        file:close()
    end

    function settings:saveToFile(_file)
        _file = _file or self.file
        if not _file then return end
        log:info(parser:assembly(settingsData))
        local file = io.open (self.file, "w+")
        file:write(parser:assembly(settingsData))
        file:close()
    end

    function settings:dump()
        log:info(help.dump(settingsData))
    end

return settings
