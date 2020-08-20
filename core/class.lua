local Class = { }

    -- Ебучая магия девида блейна
    function Class:___getInstance()
        local obj = setmetatable({
                ___class = self
            }, self)
        self.__index = self
        self.__call = function (cls, ...) return cls:new(...) end
        return obj
    end

    --- Наследование
    function Class:extend(...)
        local cls = self:___getInstance()
        cls.super = setmetatable({ }, {
                __index = self,
                __call = function (_, child, ...)
                    return self.init(child, ...)
                end
            })
        for _, param in pairs{...} do
            if type(param) == 'function' then
                param(cls, self)
            elseif type(param) == 'table' then
                for k, v in pairs(param) do
                    cls[k] = v
                end
            end
        end
        return cls
    end

    --- Создание экземпляра класса
    function Class:new(...)
        local obj = self:___getInstance()
        obj:init(...)
        return obj
    end

    --- Инициализация экземпляра класса
    function Class:init()
        -- pass
    end

    --- Проверка на совпадение класса
    function Class.isTypeOf(obj, cls)
        return obj and (obj.___class == cls)
    end

    --- Проверка на унаследованность от класса
    function Class.isInstanceOf(obj, cls)
        return obj and (obj.___class == cls or Class.isInstanceOf(obj.___class, cls))
    end

return Class
