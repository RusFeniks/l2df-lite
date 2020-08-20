local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local class = {
    storage = core:require("class.storage"),
    component = core:require("class.component")
}


local gameobject = core:require("class"):extend()


    function gameobject:new(...)
        local obj = self:___getInstance()
        obj.data = {}
        obj:initNodes(...)
        obj:initComponents(...)
        obj:init(...)
        return obj
    end


    ---Иницилизация объекта
    ---@param _kwargs table аргументы
    function gameobject:init(_kwargs)
        _kwargs = _kwargs or {  }
        self.active = true
        self.tagName = _kwargs[1]

        self.data.x = _kwargs.x or 0
        self.data.y = _kwargs.y or 0
    end


    ---Уничтожает объект, с возможностью передать его ноды родителю
    ---@param saveChilds boolean | "false" сохраняет дочерние объекты, привязывая их к родителю удаляемого объекта
    function gameobject:destroy(saveChilds)
        if saveChilds and self.parent then
            self:getNodes(function ( _node )
                self:detach(_node)
                self.parent:attach( _node )
            end)
        else
            self:getNodes(function (_node)
                _node:destroy(saveChilds)
            end)
        end
        if self.parent then self.parent:detach(self) end
        self = nil
        return
    end


    ---Создает экземпляр объекта, копируя свойства эталона
    function gameobject:clone(_kwargs)
        _kwargs = _kwargs or { }

        local obj = self:extend()
        obj.data = help.cloneTable(self.data)
        obj.active = self.active
        
        self.nodes = class.storage:new()
        self.components = class.storage:new()

        self:getNodes(function (_node)
            obj:attach(_node:clone())
        end)

        local _components = self:getComponents()
        for i = 1, #_components do
            obj:addComponent(_components[i])
        end

        return obj
    end

    ---------------------------------------
    --- NODES ---
    ---------------------------------------

    ---Создает объекты из списка nodes
    function gameobject:initNodes(_kwargs)
        self.nodes = class.storage:new()
        self.tags = class.storage:new()
        self.tagList = {}
        _kwargs = _kwargs or { }
        local _node, _class
        _kwargs.nodes = _kwargs.nodes or {}
        for _i = 1, #_kwargs.nodes do
            _node = _kwargs.nodes[_i]
            if _node and help.class(_node, gameobject) then
                self:attach(_node)
            elseif _node and _node.__option then
                _class = core:require("class.".._node.__option)
                if _class and type(_class.new) == "function" then
                    self:attach(_class:new(_node)) -- тут уже есть все необходимые проверки
                end
            end
        end
        for _i = 1, #_kwargs do
            self:addTag(_kwargs[_i])
        end
    end

    function gameobject:addTag( _tag )
        if self.tags:get(_tag) then return end
        self.tags:insert(_tag)
        log:info("tag added:", _tag)
    end

    function gameobject:removeTag( _tag )
        self.tags:remove(_tag)
    end

    function gameobject:getTags(_callback)
        local _tags = {}
        _callback = _callback or function () end
        for _id, _key in self.tags:pairs() do
            _callback(_key)
            _tags[#_tags+1] = _key
        end
        return _tags
    end

    function gameobject:getByTag( _tag, _callback )
        local _result = {  }
        _callback = _callback or function () end
        self:getNodes(function ( _node )
            if _node.tags:get(_tag) then
                _callback(_node)
                _result[#_result+1] = _node
            end
        end)
        return _result
    end

    ---Добавляет переданный объект в качестве ребенка
    function gameobject:attach(_gameobject)
        if not help.class(_gameobject, gameobject) then
            log:error("The object is absent, or is not a gameobject", self, _gameobject)
            return
        end
        if _gameobject.parent then
            log:error("The object is already someone's node", self, _gameobject, _gameobject.parent)
            return
        end
        if self:isNode(_gameobject) then
            log:error("You cannot be your own node", self)
            return
        end

        self.nodes:insert(_gameobject)
        _gameobject.parent = self
        log:success("Object " .. tostring(_gameobject) .. " attached to " .. tostring(self))
    end

    --- Проверяет является-ли объект наследником другого объекта в каких-либо проявлениях
    function gameobject:isNode(_gameobject)
        if not help.class(_gameobject, gameobject) then
            log:info("Not gameobject:", _gameobject)
            return false
        end
        if self == _gameobject then return true else
            if self.parent then
                return self.parent:isNode(_gameobject)
            else return false end
        end
    end

    --- Убирает ребенка
    function gameobject:detach(_gameobject)
        if not help.class(_gameobject, gameobject) then
            log:error("The object is absent, or is not a gameobject", self, _gameobject)
            return
        end
        self.nodes:remove(_gameobject)
        _gameobject.parent = nil
    end

    --- Получает список детей объекта. Я, кстати, хз почему мы решили называть их "узлы", но это уже прижилось, так что норм
    --- Если передана функция, она выполнится для каждой ноды
    function gameobject:getNodes(_callback, ...)
        _callback = type(_callback) == "function" and _callback or function ()  end
        local _nodes = {}
        for _id, _node in self.nodes:pairs() do
            if _node.active then _callback(_node, ...) end
            _nodes[#_nodes + 1] = _node
        end
        return _nodes, #_nodes
    end


    function gameobject:getByTagName(_tag)
        local _elements = {  }
        self:getNodes(function (_node)
            if _node.tagName and _node.tagName == _tag then
                _elements[#_elements+1] = _node
            end
        end)
        return _elements
    end


    --- Перебор дерева рекурсией, вместо цикличности. Потому что я на хую ваши выебоны ветрел и делаю так, как проще и понятнее.
    --- Компиляторы в большинстве своём, при превращении подобного в байт-код всё равно делают нормально
    --- Тем более мы не увеличиваем память этой рекурсией т.к. не инициализируем переменные, только передаем готовые
    local function nodePairs( _gameobject, _callback, _push, _pop, ... )
        if not _gameobject.active then return end
        _callback(_gameobject, ...)
        if _gameobject.nodes.count == 0 then return end
        _push(_gameobject, ...)
        for _id, _node in _gameobject.nodes:pairs() do
            nodePairs(_node, _callback, _push, _pop, ...)
        end
        _pop(_gameobject, ...)
    end

    --- Обходит дерево объектов в глубину и выполняет переданные функции
    --- _callback выполняется для каждого отдельного объекта
    --- _push и _pop вызываются при изменении глубины обхода
    function gameobject:nodePairs(_callback, _push, _pop, ...)
        _callback = type(_callback) == "function" and _callback or function ()  end
        _push = type(_push) == "function" and _push or function ()  end
        _pop = type(_pop) == "function" and _pop or function ()  end
        nodePairs(self, _callback, _push, _pop, ...) -- делаю рекурсионной отдельную функцию, чтобы по 100 раз не проверять функции на валидность
        return
    end

    ---------------------------------------
    --- COMPONENTS ---
    ---------------------------------------

    function gameobject:initComponents(_kwargs)
        self.components = class.storage:new()
    end

    function gameobject:addComponent(_component, ...)
        if not help.class(_component, class.component) then
            log:error("The object is absent, or is not a component", self, _component)
            return
        end
        local _list, _count = self:getComponents(_component.___class)
        --[[if _component.unique and _count > 0 then
            log:warn("Not possible to add a unique component because gameobject already contains its instance", self, _component, _list[1])
            return
        end]]
        self.components:insert(_component)
        self.data[_component] = {}
        _component:added(self, ...)
        log:success("Component " .. tostring(_component) .. " added to object " .. tostring(self))
    end

    function gameobject:getComponents(_class)
        local _components = {}
        for _id, _component in self.components:pairs() do
            if not _class or help.class(_component, _class.___class) then
                _components[#_components + 1] = _component
            end
        end
        return _components, #_components
    end

    function gameobject:getComponent(_class)
        return self:getComponents(_class)[1]
    end

    function gameobject:removeComponent(_component, ...)
        if not help.class(_component, class.component) then
            log:error("The object is absent, or is not a component", self, _component)
            return
        end
        if self.components:remove(_component) then
            _component:removed(self, ...)
            self[_component] = nil
            log:success("Component "..tostring(_component).." was removed from object "..tostring(self))
            return
        end
        local _list = self:getComponents(_component)
        for i = 1, #_list do
            self:removeComponent(_list[i], ...)
        end
        return
    end

    function gameobject:componentsEvent(_event, _class, ...)
        if not _event then return end
        local _components = self:getComponents(_class)
        local _r
        for i = 1, #_components do
            local _r = type(_components[i][_event]) == "function" and _components[i][_event](_components[i], self, ...)
        end
    end

return gameobject
