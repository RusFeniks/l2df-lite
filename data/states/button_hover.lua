local log = L2DF:require("log")

return function ( _gameobject, _data, _vars )
    if _data.clicked then
        _gameobject:clicked()
        _gameobject:setFrameByTrigger("click")
        _data.clicked = false
        _data.blocked = true
    elseif _data.hovered then
        _gameobject:setFrameByTrigger("hover")
    end
    _data.hovered = false
end