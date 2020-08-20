local log = L2DF:require("log")
local sceneManager = L2DF:require("manager.scene")

local scene = L2DF:initScene("scenes/layout/main_menu.dat")

local function setRandomBG ()
    scene:getByTag("bg_image", function ( _bgImg )
        _bgImg.data.pic = math.random( 1, 13 )
    end)
end

scene:getByTag("button", function ( _button )
    _button.clicked = function ( self )
        log:info("i'm clicked!")
    end
end)

scene:getByTag("game_start", function ( _button )
    local clicked = _button.clicked
    _button.clicked = function ( self )
        clicked(_button)
        setRandomBG()
    end
end)

scene:getByTag("control_settings", function ( _button )
    local clicked = _button.clicked
    _button.clicked = function ( self )
        clicked(_button)
        sceneManager:push("controls")
    end
end)

scene:getByTag("recording_info", function ( _button )
    local clicked = _button.clicked
    _button.clicked = function ( self )
        scene.data.camera.ox = scene.data.camera.ox + 5
    end
end)

scene:getByTag("oficial_website", function ( _button )
    local clicked = _button.clicked
    _button.clicked = function ( self )
        scene.data.camera.ox = scene.data.camera.ox - 5
    end
end)

local _push = scene.push
function scene:push()
    _push(self)
    setRandomBG()
end

return scene