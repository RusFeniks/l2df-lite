local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local manager = {

}

local class = {

}

local component = core:require("class"):extend()

    function component:init()
        -- body
    end

    function component:added(_gameobject, _input)
        -- body
    end

    function component:removed()
        -- body
    end

return component
