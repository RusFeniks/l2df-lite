local log = L2DF:require("log")

return function ( _gameobject, _data, _vars )
    _data.x = math.random(100, 1000)
    _data.y = math.random(50, 500)
end