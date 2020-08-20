local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local storage = core:require("class"):extend()

    function storage:init(_elements)
        self.list = {}
        self.map = {}
        self.free = {}
        self.lenght = 0
        self.count = 0
    end

    --- добавляет элемент в хранилище, возвращая его id
    function storage:insert( _element, _mapId )
        if not _element then return end
        _mapId = _mapId or _element
        local _id
        if #self.free > 0 then
            _id = self.free[#self.free]
            self.free[#self.free] = nil
        else
            self.lenght = self.lenght + 1
            _id = self.lenght
        end
        self.list[_id] = _element
        self.map[_mapId] = _id
        self.count = self.count + 1
        return _id
    end

    function storage:remove( _mapId )
        if not _mapId then return false end
        local _id = self:getId(_mapId)
        if not _id or _id > self.lenght then return false end
        self.list[_id] = nil
        self.map[_mapId] = nil
        self.count = self.count + 1
        if _id == self.lenght then
            self.lenght = self.lenght - 1
        else
            self.free[#self.free + 1] = _id
        end
        return true
    end

    function storage:get( _mapId )
        return self.list[self.map[_mapId]]
    end

    function storage:getId( _mapId )
        return self.map[_mapId]
    end

    function storage:pairs()
        local _id, _element
        return function ()
            _id, _element = next(self.list, _id)
            return _id, _element
        end
    end

    function storage:enum()
        local _id = 0
        return function ()
            while true do
                _id = _id + 1
                if _id > self.lenght then return nil end
                if self.list[_id] then return self.list[_id] end
            end
        end
    end

return storage
