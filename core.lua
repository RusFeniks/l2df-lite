local requirements = {}
local path = ...

local functionsList = {}

local function hook( _function, _callback )
    local _old_function = _function or function (  ) end
    _function = function ( ... )
        _callback(...)
        _old_function(...)
    end
    return _function
end

local function availableForTheHook (eventsList)
    if type(eventsList) ~= "table" then return end
    for _key, _val in pairs(eventsList) do
        functionsList[_key] = functionsList[_key] or { }
        love[_key] = hook(love[_key], function ( ... )
            for _i = 1, #functionsList[_key] do
                functionsList[_key][_i]( ... )
            end
        end)
    end
end


local core = { _VERSION = 1.0, _PATH = path }

    function core:init( _kwargs )

        availableForTheHook(love.handlers)
        availableForTheHook({update = love.update, draw = love.draw})

        self:require("log"):init()
        self:require("help"):init()
        self:require("parser"):init()
        self:require("builder"):init()

        self:require("log"):info("> Modules initalization finished")

        self:require("manager.settings"):init(_kwargs)

        self:require("manager.render"):init()

        self:require("manager.fabric"):init()
        self:require("manager.resource"):init()
        self:require("manager.font"):init()
        self:require("manager.event"):init()
        self:require("manager.scene"):init()
        self:require("manager.physics"):init()
        self:require("manager.sound"):init()
        self:require("manager.control"):init()

        self:require("log"):success("Core initialized success!")
        self:require("log"):info("Core version: " .. self._VERSION)
        self:require("log"):info("Path to core: " .. self._PATH)
        self:require("log"):print("--------------------------------")

    end

    function core:require(_path )
        if not _path then return nil end
        local _exist, _module = pcall(require, self._PATH .. "." .. _path)
        if _exist and type(_module) == "table" then return _module end
        return nil
    end

    function core:import( _path )
        return core:require( _path )
    end

    function core:hook( _event, _callback )
        if not functionsList[_event] then
            self:require("log"):warn("Event " .. _event .. " doesn't exist!")
            return
        end
        functionsList[_event][#functionsList[_event]+1] = _callback
        self:require("log"):info("- Event " .. _event .. " was successful hooked!")
    end

return core
