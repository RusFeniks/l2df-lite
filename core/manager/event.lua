local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local class = {
    storage = core:require("class.storage")
}

local insert = table.insert
local remove = table.remove

local subscribers = {}
local funcStack = {}

local event = {}

    local function hook(_event)
        return function (...)
            _event(...)
            event:call(_event, nil, ...)
        end, _event
    end

    function event:init(  )
        local _val

        core:hook("update", function ( ... )
            self:call("update", love, ...)
        end) -- подписываем менеджер на update love2d
        
        if love then
            for key,val in pairs(love.handlers) do
                core:hook(key, function ( ... )
                    self:call(key, love, ...)
                end)
            end -- подписываем менеджер на все возможные love2d ивенты
        end

        log:success("Event manager initialized!")
    end

    --- Подписывает вызов функции (коллбэка) на определенное событие
    function event:subscribe( _event, _callback, _target )
        if not _event then return end
        if (type(_callback) ~= "function") then
            log:error("Callback is not a function!", _event, _callback)
            return
        end
        subscribers[_event] = subscribers[_event] or {}
        _target = _target or "global" -- определяем, подписывать на любой вызов события или только от конкретного источника
        subscribers[_event][_target] = subscribers[_event][_target] or class.storage:new()
        subscribers[_event][_target]:insert(_callback)
        log:info("Subscribed to event", _event, _callback)
    end

    --- Отписывает от всех событий указанного типа
    function event:unsubscribe( _event, _callback )
        log:info("Unsubscribed to event", _event, _callback)
        for _target in pairs(subscribers[_event]) do
            subscribers[_event][_target]:remove(_callback)
        end
    end

    function event:call( _event, _target, ... )
        if not (_event and subscribers[_event]) then return end
        if subscribers[_event].global then
            for _id, _callback in subscribers[_event].global:pairs() do
                _callback(_target, ...)
            end
        end
        if subscribers[_event][_target] then
            for _id, _callback in subscribers[_event][_target]:pairs() do
                _callback(_target, ...)
            end
        end
    end

    function event:hook( _event, _callback )
        _event = _event or function (...) end
        if not funcStack[_event] then
            local _call
            _event, _call = hook(_event)
            funcStack[_event] = _call
        end
        self:subscribe(funcStack[_event], _callback)
        return _event
    end

return event
