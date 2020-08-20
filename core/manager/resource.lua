local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")
assert( love, "This manager require love2d framework to stable working")

local log = core:require("log")
local help = core:require("help")
local fs = love and love.filesystem

local class = {
    storage = core:require("class.storage"),
    plug = core:require("class.plug")
}

local resource = {}

    local resources = class.storage:new()
    local formats = {
        [".png"] = {
            loadData = love.image.newImageData,
            createResource = love.graphics.newImage
        },
        [".mp3"] = {
            loadData = love.sound.newSoundData,
            createResource = function ( data )
                return love.audio.newSource(data, "stream")
            end
        },
        [".wav"] = {
            loadData = love.sound.newSoundData,
            createResource = function ( data )
                return love.audio.newSource(data, "static")
            end
        },
    }

    local function getFileExtension(url)
        return url:match("^.+(%..+)$")
    end

    local function fileCheck ( _filepath )
        if type(_filepath) ~= "string" or _filepath == "" then
            log:warn("Filepath must be a string")
            return false
        end
        if not fs.getInfo(_filepath) then
            log:warn("File is not found")
            return false
        end
        if not formats[getFileExtension(_filepath)] then
            log:warn("Resource extension is not supported")
            local _s = "Supported extensions: "
            for key in pairs(formats) do
                _s = _s .. key .. " "
            end
            log:info(_s)
            return false
        end
        return true
    end

    local function addLoadedResourse(_resource, _filepath)
        _filepath = _filepath or _resource
        resources:insert(_resource, _filepath)
    end

    local asyncTurn = {}
    local asyncMap = {}
    local callbackTurn = {}

    local function asyncLineUp(_filepath, _ext, _callback, _reload)

        if asyncMap[_filepath] then
            local _turn_id = asyncMap[_filepath]
            local _old = callbackTurn[_turn_id]
            callbackTurn[_turn_id] = function ( _resource, _filepath )
                _old(_resource, _filepath)
                _callback(_resource, _filepath)
            end
            log:warn("callback modified")
            return
        end

        local _turn = { filepath = _filepath, ext = _ext }
        _turn.id = tostring(_turn)
        asyncMap[_filepath] = _turn.id
        asyncTurn[#asyncTurn + 1] = _turn
        callbackTurn[_turn.id] = _callback
    end

    local asyncPush = love.thread.getChannel( "asyncPush" )
    local asyncPop = love.thread.getChannel( "asyncPop" )

    local asyncLoader = love.thread.newThread [[
        require 'love.image'
        require 'love.video'
        require 'love.sound'

        local formats = {
            [".png"] = love.image.newImageData,
            [".mp3"] = love.sound.newSoundData,
            [".wav"] = love.sound.newSoundData,
        }

        local asyncPush = love.thread.getChannel( "asyncPush" )
        local asyncPop = love.thread.getChannel( "asyncPop" )
        local _working = true
        local _element
        while _working do

            _element = asyncPush:pop()
            if _element then
                _element.resource = formats[_element.ext](_element.filepath)
                asyncPop:push(_element)
            else
                collectgarbage()
                _working = false
            end

        end
    ]]

    function resource:init()
        assert(fs, "Resource manager requires file system functions")
        core:hook("update", function ( ... ) self:update( ... ) end)
        log:success("Resourse manager initialized!")
    end

    function resource:update()
        if #asyncTurn > 0 then
            if not asyncLoader:isRunning() then asyncLoader:start() end
            asyncPush:push(asyncTurn[#asyncTurn])
            asyncTurn[#asyncTurn] = nil
        end
        if asyncPop:getCount() > 0 then
            local _element = asyncPop:pop()
            _element.resource = formats[_element.ext].createResource(_element.resource)
            callbackTurn[_element.id](_element.resource, _element.filepath)
            callbackTurn[_element.id] = nil
            addLoadedResourse(_element.resource, _element.filepath)
            log:success("Resource loaded (async):", _element.filepath, _element.resource)
        end
    end

    function resource:load(_filepath, _callback)
        if self:has(_filepath) then
            return self:get(_filepath)
        end
        if not fileCheck(_filepath) then return class.plug:new(_filepath) end
        local _ext = getFileExtension(_filepath)
        _callback = _callback or function ()  end

        local _data = formats[_ext].loadData(_filepath)
        local _resource = formats[_ext].createResource(_data)

        _callback(_resource, _filepath)

        log:success("Resource loaded: ", _filepath, _resource)
        addLoadedResourse(_resource, _filepath)

        return
    end

    function resource:loadASYNC(_filepath, _callback)
        if self:has(_filepath) then 
            _callback = _callback or function ()  end
            _callback(self:get(_filepath), _filepath)
            return self:get(_filepath) end
        if not fileCheck(_filepath) then return end
        _callback = _callback or function ()  end
        asyncLineUp(_filepath, getFileExtension(_filepath), _callback)
        return class.plug:new()
    end

    function resource:remove(_filepath)
        resources:remove(_filepath)
    end

    function resource:get(_filepath)
        return resources:get(_filepath)
    end

    function resource:has(_filepath)
        return resources:getId(_filepath)
    end

    function resource:getTurn()
        return #asyncTurn
    end

    function resource:checkTurn()
        return asyncLoader:isRunning() or #asyncTurn > 0
    end


return resource
