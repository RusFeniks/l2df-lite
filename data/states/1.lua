return function ( _data, _vars )
    _data.dvx = _data.key.left and _data.key.left.delayed and _vars.x or _data.dvx
    _data.dvx = _data.key.right and _data.key.right.delayed and _vars.x or _data.dvx

    _data.facing = false
        or _data.key.right and (_data.key.right.delayed or _data.key.right.pressed) and 1
        or _data.key.left and (_data.key.left.delayed or _data.key.left.pressed) and -1
        or _data.facing

    _data.dvx = _data.key.left and _data.key.left.double_pressed and _vars.x * 5 or _data.dvx
    _data.dvx = _data.key.right and _data.key.right.double_pressed and _vars.x * 5 or _data.dvx

    _data.dvy = _data.key.up and _data.key.up.pressed and -_vars.y or _data.dvy
    _data.dvy = _data.key.up and _data.key.up.double_pressed and -_vars.y or _data.dvy
end
