local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local manager = {
    sound = core:require("manager.sound"),
    resource = core:require("manager.resource")
}

local sound = core:require("class.component"):extend()

    local soundmap = { }

    function sound:init()
        -- body
    end

    function sound:added(_gameobject, _kwargs)
        local _data = _gameobject.data
        local _storage = _data[self]
        _kwargs = _kwargs or {  }

        _data.sound = _data.sound or nil

        for i = 1, #_kwargs do
            self:add(_kwargs[i])
        end
    end

    function sound:add(_filepath, _id)
        _id = _id or _filepath
        manager.resource:loadASYNC(_filepath, function (  )
            soundmap[_id] = _filepath
        end)
    end

    local function play(_id)
        if not soundmap[_id] then return end
        manager.sound:add({
            resource = manager.resource:get(soundmap[_id])
        })
    end

    local soundAction = {
        string = function (_id)
            play(_id)
        end,
        table = function (_ids)
            for i = 1, #_ids do
                play(_ids[i])
            end
        end
    }

    function sound:update(_gameobject)
        local _s = _gameobject.data.sound
        _gameobject.data.sound = soundAction[type(_s)] and soundAction[type(_s)](_s) or { }
    end

return sound
