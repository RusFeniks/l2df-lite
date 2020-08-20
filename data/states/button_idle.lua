local log = L2DF:require("log")

return function ( _gameobject, _data, _vars )
    _data.blocked = false
    if _data.hovered then
        _gameobject:setFrameByTrigger("hover")
    end
    
end