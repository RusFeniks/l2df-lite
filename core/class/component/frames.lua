local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local frames = core:require("class.component"):extend()

    function frames:added(_gameobject, _kwargs)
        _kwargs = _kwargs or {  }
        local _data = _gameobject.data
        local _storage = _gameobject.data[self]

        _storage.frames = {}

        _data.frame = _data.frame or 0
        _data.wait = _data.wait or 0
        _data.next = _data.next or 0

        _data.fchanged = _data.fchanged or true

        ---Генерация фреймов
        _kwargs.frames = _kwargs.frames or { }

        for _i = 1, #_kwargs.frames do
            self:add(_gameobject, _kwargs.frames[_i])
        end
        ---------------------

        ---Назначение триггеров

        _data.triggers = _data.triggers or {}
        _kwargs.triggers = _kwargs.triggers or { }
        
        for _trigger, _frame in pairs(_kwargs.triggers) do
            _data.triggers[_trigger] = _frame
        end

        ----------------------

        _gameobject.setFrame = function ( _gameobject, _id )
            self:set( _gameobject, _id )
        end

        _gameobject.setFrameByTrigger = function ( _gameobject, _trigger )
            self:set( _gameobject, _data.triggers[_trigger] )
        end

        self:set(_gameobject, _kwargs.frame or 1)
    end

    function frames:add(_gameobject, _frame)

        if type(_frame) ~= "table" then return end
        local _storage = _gameobject.data[self]

        local _id = _frame[1]
        _frame[1] = nil

        _storage.frames[_id] = {
            key = {},
            value = {},
            wait = _frame.wait or 1,
        }

        _frame.wait = nil

        local _current = _storage.frames[_id]
        local _i = 1
        for _key, _value in pairs(_frame) do
            _current.key[_i] = _key
            _current.value[_key] = _value
            _i = _i + 1
        end

    end

    function frames:remove( _gameobject, _id )
        local _storage = _gameobject.data[self]
        _storage.frames[_id] = nil
    end

    function frames:set( _gameobject, _id )
        if not _id then return end
        local _data = _gameobject.data
        local _frame = _data[self].frames[_id]
        if not _frame then return end
        _data.wait = _frame.wait
        _data.fchanged = _data.frame ~= _id and true or false
        _data.frame = _id
    end


    function frames:update(_gameobject)
        local _data = _gameobject.data
        
        _data.fchanged = false
        if _data.wait < 1 then
            self:set(_gameobject, _data.next)
        end

        local _frame = _data[self].frames[_data.frame]
        if not _frame then return end
        for _i = 1, #_frame.key do
            _data[_frame.key[_i]] = _frame.value[_frame.key[_i]]
        end
        _data.wait = _data.wait - 1
    end

return frames
