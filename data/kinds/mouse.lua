local log = L2DF:require("log")
local controlManager = L2DF:require("manager.control")

return function ( _itr, _bdy )
    if _bdy.data.blocked then return end
    _bdy.data.hovered = true
    if _bdy.data.hovered and controlManager:pressed("mouse1") then
        _bdy.data.clicked = true
    end
end