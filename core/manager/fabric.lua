local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")
assert( love, "This manager require love2d framework to stable working")

local log = core:require("log")
local help = core:require("help")
local gameobject = core:require("class.gameobject")

local fabric = {}

    local presetS = {}

    ---Инициализация менеджера
    function fabric:init()
        log:success("Fabric manager initialized!")
    end

    ---Получает объект прессета по его Id
    ---@param _presetId string id
    ---@return table прессет
    function fabric:getPreset(_presetId)
        return presetS[_presetId]
    end

    ---Добавляет в фабрику новый прессет
    ---@param _presetId string id под которым будет хранится прессет в фабрике
    ---@param _preset table объект прессета
    function fabric:addPreset(_presetId, _preset)
        if self:getPreset(_presetId) then
            log:warn("preset with id "..tostring(_presetId).." already created!")
            return false
        end
        if not (_preset.isInstanceOf and _preset.isInstanceOf(gameobject)) then
            log:warn("This is not a preset")
            return false
        end
        presetS[_presetId] = _preset
        return true
    end

    ---Создает объект, используя указанный прессет
    ---@param _presetId string id прессета
    ---@param _kwargs table параметры
    function fabric:create(_presetId, _kwargs)
        local _preset = fabric:getPreset(_presetId)
        if not _preset then
            log:warn("preset with id ".. _presetId .." is not exist")
            return
        end
        _kwargs = _kwargs or {}
        if type(_preset.clone) == "function" then
            return _preset:clone(_kwargs)
        else
            return _preset:new(_kwargs)
        end
    end

return fabric