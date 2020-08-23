math.randomseed(os.time())
local core = require( "core" )
L2DF = core
DEBUG = true

function love.load(  )
    core:init({
        settingsFile = "data/settings.dat"
    })

    local loader = core:require("loader")
    local scenes = core:require("manager.scene")
    local font = core:require("manager.font")

    local set = core:require("manager.settings")

    font:preload("data/fonts.dat")

    for _fileName, _fileData in loader:requireDirectory( "scenes" ) do
        scenes:load(_fileName, _fileData)
    end

    core:require("manager.scene"):set("preloader")

end

function love.update(  )
    love.window.setTitle("L2DF-Lite | FPS: " .. tostring(love.timer.getFPS()))
end

function love.draw()

end
