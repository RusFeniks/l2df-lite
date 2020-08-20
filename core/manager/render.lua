local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")
assert( love, "This manager require love2d framework to working")

local log = core:require("log")
local help = core:require("help")

local class = {
    storage = core:require("class.storage")
}

local draw = love.graphics.draw
local printf = love.graphics.printf
local rectangle = love.graphics.rectangle
local clear = love.graphics.clear

local loveNewFont = love.graphics.newFont

local min = math.min

local convertColor = help.convertColor

local render = {}

    ---Разрешение игры, его будет использовать основной холст
    local resolutionX = 0
    local resolutionY = 0
    
    ---Параметры основного холста
    local mainCanvas = love.graphics.newCanvas( )
    local mainCanvasOffsetX = 0
    local mainCanvasOffsetY = 0
    local mainCanvasScaleX = 1
    local mainCanvasScaleY = 1
    local mainCanvasRatio = true

    ---Текущие размеры окна
    local windowWidth = 0
    local windowHeight = 0

    ---Слои для отрисовки
    local layersMap = {}
    local layers = {}


    ---Функция отрисовки самого объекта, в зависимости от его типа
    local function drawElement( _e )
        if _e.resource then
            if not (_e.resource.typeOf and _e.resource:typeOf("Drawable")) then return end
            draw(_e.resource, _e.sprite, _e.x, _e.y, _e.r, _e.sx, _e.sy, _e.ox, _e.oy, _e.kx, _e.ky)
        elseif _e.text then
            if not type(_e.text == "string") then return end
            printf( _e.text, _e.x, _e.y, _e.limit or loveNewFont():getWidth(_e.text) )
        elseif _e.fill then
            rectangle( _e.fill, _e.x1, _e.y1, _e.x2 - _e.x1, _e.y2 - _e.y1 )
        end
    end

    ---Изменение размера окна
    local function resize (_width, _height)
        if mainCanvasRatio then
            mainCanvasScaleX = min(_width / resolutionX, _height / resolutionY)
            mainCanvasScaleY = mainCanvasScaleX
        else
            mainCanvasScaleX = _width / resolutionX
            mainCanvasScaleY = _height / resolutionY
        end
        windowWidth, windowHeight = _width, _height
        mainCanvasOffsetX = (_width - resolutionX * mainCanvasScaleX) * 0.5
        mainCanvasOffsetY = (_height - resolutionY * mainCanvasScaleY) * 0.5
    end

    ---Подготовка холста
    local function canvasInit ()
        love.graphics.setDefaultFilter("nearest", "nearest")
        
        resolutionX = core:getSettings("graphics.gameWidth", 977)
        resolutionY = core:getSettings("graphics.gameHeight", 550)
        
        windowWidth, windowHeight = resolutionX, resolutionY
        love.window.setMode( windowWidth, windowHeight, {
            resizable = true,
            fullscreen = core:getSettings("graphics.fullscreen", false),
        })

        mainCanvasRatio = core:getSettings("graphics.ratio", true)

        mainCanvas = love.graphics.newCanvas( resolutionX, resolutionY )
    end


    ---Сортировка слоёв
    local function layersSort ()
        table.sort (layers, function (a, b) return (a.index < b.index) end)
        layersMap = {}
        for i = 1, #layers do
            layersMap[layers[i].name] = i
        end
    end

    ---Добавление слоя
    local function layersAdd (_layer)
        local _id = layersMap[_layer.name] or #layers + 1
        layers[_id] = _layer
        layersSort()
    end

    ---Удаление слоя
    local function layersRemove (_name)
        if not layersMap[_name] then return end
        table.remove( layers, layersMap[_name] )
        layersMap[_name] = { }
    end

    ---Инициализация менеджера
    function render:init()
        core.getSettings = core.getSettings or function (_, _, _value)
            return _value
        end

        canvasInit()
        resize(windowWidth, windowHeight)
        
        core:hook("update", function ( ... )
            mainCanvas:renderTo( function ( ... )
                self:update(...)
            end)
        end)

        core:hook("draw", function ( ... )
            love.graphics.draw(mainCanvas, mainCanvasOffsetX, mainCanvasOffsetY, 0, mainCanvasScaleX, mainCanvasScaleY)
        end)

        core:hook("resize", resize)

        log:info("Render manager create hook to draw function for draw objects on screen")
        log:success("Render manager initialized!")
    end
    
    function render:getScaleInfo()
        return mainCanvasScaleX, mainCanvasScaleY, mainCanvasOffsetX, mainCanvasOffsetY
    end

    ---Перезагрузка графики, инициилизирует холст заново
    function render:reload( )
        canvasInit()
        resize(windowWidth, windowHeight)
    end

    ---Love2d использует quad'ы для отрисовки определенных частей спрайт-листа. Тут мы создаём этот самый квад.
    ---Эту функцию вызывают компоненты. Она вынесена в менеджер т.к. способ создания quad'а может измениться в будующем и я не хочу править все компоненты
    function render:addQuad(...)
        return love.graphics.newQuad(...)
    end

    ---Эта функция просто рисует объекты, лежащие в массиве layers.
    ---Как правильно заполнять массив, смотри в функции render:draw()
    function render:update()

        clear()

        local _layer, _ox, _oy, _scale, _bg
        for _id = 1, #layers do
            
            _layer = layers[_id]
            
            _ox = _layer.camera.ox
            _oy = _layer.camera.oy
            _scale = _layer.camera.scale

            _bg = _layer.background

            _layer.canvas:renderTo( function ( ... )
                love.graphics.clear( _bg[1], _bg[2], _bg[3], _bg[4] )
                for _index = 1, #_layer.z do
                    for _e = 1, #_layer.z[_index] do
                        drawElement(_layer.z[_index][_e])
                    end
                    _layer.z[_index] = { }
                end
            end)
            
            draw(_layer.canvas, 0, 0, 0, _scale, _scale, _ox, _oy )

        end
    end

    ---Добавление элемента в список на отрисовку
    function render:draw( _element )
        if not (_element and _element.layer) then return end

        local _layer = layers[layersMap[_element.layer]] or layers[#layers]
        if not _layer then return end

        local _index = _element.z and ((_element.z > #_layer.z and #_layer.z) or (_element.z < 1 and 1)) or _element.z or 1
        _layer.z[_index][#_layer.z[_index] + 1] = _element
    end



    ---------------------------------------
    --- LAYERS ---
    ---------------------------------------

    function render:addLayer(_name, _kwagrs)
        if not _name then return end
        
        _kwagrs = _kwagrs or { }

        _kwagrs.width = _kwagrs.width or resolutionX
        _kwagrs.height = _kwagrs.height or resolutionY

        _kwagrs.camera = _kwagrs.camera or { 
            ox = 0,
            oy = 0,
            scale = 1
         }

        _kwagrs.zWidth = _kwagrs.zWidth or 1
        _kwagrs.zIndex = _kwagrs.zIndex or #layers+1

        _kwagrs.background = _kwagrs.background or { 0,0,0,0 }

        local _layer = {
            background = {
                (_kwagrs.background[1] or 0) / 255,
                (_kwagrs.background[2] or 0) / 255,
                (_kwagrs.background[3] or 0) / 255,
                (_kwagrs.background[4] or 0) / 100,
            },
            canvas = love.graphics.newCanvas( _kwagrs.width, _kwagrs.height ),
            camera = _kwagrs.camera,
            height = _kwagrs.height,
            index = _kwagrs.zIndex,
            name = _name,
            width = _kwagrs.width,
            z = { },
        }

        -- Подготовка Z-слоёв
        for _i = 1, _kwagrs.zWidth do
            _layer.z[_i] = {}
        end

        layersAdd(_layer)
    end

    function render:removeLayer(_name)
        layersRemove(_name)
    end

return render
