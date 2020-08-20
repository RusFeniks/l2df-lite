local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local print = _G.print

local log = {}

    local function _print( prefix, ... )
        print("[".. os.date("%X") .."] " .. (prefix and prefix .. "" or ""), ...)
    end

    function log:init(  )
        self:success("Log module initialized!")
    end

    function log:print( ... )
        _print("\x1b[0m[MESSAGE]\x1b[0m", ...)
    end

    function log:info( ... )
        _print("\x1b[37m[INFO]\x1b[0m", ...)
    end

    function log:warn( ... )
        _print("\x1b[33m[WARN]\x1b[0m", ...)
    end

    function log:error( ... )
        _print("\x1b[31m[ERROR]\x1b[0m", ...)
    end

    function log:success( ... )
        _print("\x1b[32m[SUCCESS]\x1b[0m", ...)
    end

return log
