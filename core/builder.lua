local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local parser = core:require("parser")

local fs = love.filesystem

local builder = {}

    function builder:init()
        log:success("Builder module initialized!")
    end

    function builder:create( class, layout )
        if not type(class.new) == "function" then
            log:warn(tostring(class) .. "is not a class!")
            return nil
        end
        local _kwargs = {}
        if type(layout) == "string" then
            if fs.getInfo(layout) then layout = fs.read(layout) end
            _kwargs = parser:parse(layout)
        elseif type(layout) == "table" then
            _kwargs = layout
        end
        return class:new(_kwargs)
    end

return builder