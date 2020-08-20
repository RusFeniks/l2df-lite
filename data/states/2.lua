return function ( _data, _vars )
    _data.x = love.mouse.getX( )
    _data.y = love.mouse.getY( )
    _data.z = 0
    if _data.key.attack and _data.key.attack.pressed then
        _data.sound = "test.wav"
    end
end
