local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")
local builder = core:require("builder")

local class = {
    scene = core:require("class.scene")
}

local scene = {}

    local SCENES = {}
    ---Стек сцен, для быстрых переходов между ними без потери данных
    local STACK = {}

    local function callFunction(_function, _target, _component, ...)
        local _input = _target and _target.data or { }
        _target:nodePairs(function ( _gameobject, input, ... )
            _gameobject:componentsEvent(_function, _component, _input, ...)
        end)
    end

    function scene:init( ... )
        core:hook("update", function ( ... )
            if #STACK < 1 then return end
            for _i = 1, #STACK - 1 do
                STACK[_i]:updateBackground(...)
                callFunction("updateBackground", STACK[_i], nil, ...)
            end
            callFunction("update", STACK[#STACK], nil, ...)
        end) -- подписываем менеджер на update love2d

        for key,val in pairs(love.handlers) do
            core:hook(key, function ( ... )
                if not STACK[#STACK] then return end
                callFunction(key, STACK[#STACK], nil, ...)
            end)
        end -- подписываем менеджер на все возможные love2d ивенты

        assert(not core.initScene, "Function core.initScene already exists!")
        core.initScene = function ( self, layout )
            return builder:create(class.scene, layout)
        end
        log:success("Scene manager create hook to core:initScene function")

        log:success("Scenes manager initialized!")
    end

    function scene:load(_id, _scene)
        _scene = _scene or _id
        if not help.class(_scene, class.scene) then
            log:error("The object is absent, or is not a scene")
            return
        end
        SCENES[_id] = _scene
        log:success("Scene " .. tostring(_id) .. " loaded", _scene)
    end

    function scene:inStack(_id)
        if not _id then return end
        local _scene = SCENES[_id]
        for i = 1, #STACK do
            if STACK[i] == _scene then return true end
        end
        return false
    end

    function scene:getActive()
        if #STACK > 0 then return STACK[#STACK] end
        return nil
    end

    function scene:push(_id)
        if not _id or not SCENES[_id] then
            log:warn("Scene not exist!")
            return
        end
        SCENES[_id] = SCENES[_id] or scene:load(_id)
        STACK[#STACK + 1] = SCENES[_id]
        SCENES[_id]:push()
    end

    function scene:pop(_count)
        _count = type(_count) == "number" and _count or 1
        for i = 1, _count do
            if #STACK > 0 then
                STACK[#STACK]:pop()
                STACK[#STACK] = nil
                if #STACK > 0 then
                    STACK[#STACK]:recovery()
                end
            end
        end
    end

    function scene:set(_id)
        scene:pop(#STACK)
        scene:push(_id)
    end

return scene
