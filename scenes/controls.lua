local sceneManager = L2DF:require("manager.scene")

local scene = L2DF:initScene("scenes/layout/controls.dat")

    local function setRandomBG ()
        scene:getByTag("bg_image", function ( _bgImg )
            _bgImg.data.pic = math.random( 1, 13 )
        end)
    end

    scene:getByTag("cancel", function ( _button )
        local clicked = _button.clicked
        _button.clicked = function ( self )
            clicked(_button)
            sceneManager:pop()
        end
    end)

    local _push = scene.push
    function scene:push()
        _push(self)
        setRandomBG()
    end

return scene