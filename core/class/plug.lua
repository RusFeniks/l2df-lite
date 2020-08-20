local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local plug = core:require("class"):extend()

    function plug:init()

    end

return plug
