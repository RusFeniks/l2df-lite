local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")
assert( love, "This manager require love2d framework to stable working")

local log = core:require("log")
local help = core:require("help")

local control = {}

    local holdedMap = {  }
    local pressedMap = {  }
    local doublePressedMap = {  }
    local doubleHoldedMap = {  }

    local timer = 0

    local pressTime = 3
    local holdDelay = 7
    local doublePressedTime = 15

    local keyList = { }
    local keyMap = { }

    
    local function keypressed( _key, _scancode )
        
        if pressedMap[_scancode] and timer - pressedMap[_scancode] < doublePressedTime then
            doubleHoldedMap[_scancode] = true
            doublePressedMap[_scancode] = timer
        end

        holdedMap[_scancode] = true
        pressedMap[_scancode] = timer

    end

    local function keyreleased( _key, _scancode )
        holdedMap[_scancode] = false
        doubleHoldedMap[_scancode] = false
    end
       


    function control:init(_kwargs)
        
        _kwargs = _kwargs or { }
        
        pressTime = _kwargs.pressTime or pressTime
        holdDelay = _kwargs.holdDelay or holdDelay
        doublePressedTime = _kwargs.doublePressedTime or doublePressedTime

        core:hook("update", function ( ... ) self:update(...) end)
        core:hook("keypressed", function ( ... ) keypressed(...) end)
        core:hook("keyreleased", function ( ... ) keyreleased(...) end)
        
        core:hook("mousepressed", function ( x, y, button, istouch, presses )
            button = "mouse" .. button
            keypressed( button, button )
        end)
        
        core:hook("mousereleased", function ( x, y, button, istouch, presses )
            button = "mouse" .. button
            keyreleased( button, button )
        end)
        
        log:success("Control manager initialized!")
    end

    
    function control:update( dt )
        timer = timer + 1
    end


    function control:setKey( _scancode, _key, _player )
        if _player then
            keyList[_player] = keyList[_player] or { }
            keyList[_player][_key] = _scancode
            keyMap[_scancode] = keyList[_player][_key]
        else
            keyList[_key] = _scancode
            keyMap[_scancode] = keyList[_key]
        end
    end
    

    function control:holded( _scancode )
        return holdedMap[_scancode] and (timer - pressedMap[_scancode]) > holdDelay
    end

    function control:doubleHolded( _scancode )
        return doubleHoldedMap[_scancode] and (timer - pressedMap[_scancode]) > holdDelay
    end

    function control:pressed( _scancode )
        return pressedMap[_scancode] and (timer - pressedMap[_scancode]) <= pressTime
    end

    function control:doublePressed( _scancode )
        return doublePressedMap[_scancode] and (timer - doublePressedMap[_scancode]) <= pressTime
    end

return control
