local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local help = core:require("help")

local manager = {
    resource = core:require("manager.resource"),
    sound = core:require("manager.sound"),
    render = core:require("manager.render"),
}

local scene = core:require("class.gameobject"):extend()

    function scene:init(_kwargs)
        _kwargs = _kwargs or {  }
        
        self:super(_kwargs)
        self.active = false
        
        self.data.music = _kwargs.music or false
        self.data.layer = _kwargs.layer or self
        
        self.data.camera = { ox = 0, oy = 0, scale = 1 }
        self.data.background = _kwargs.background
        self.data.width = _kwargs.width
        self.data.height = _kwargs.height
        self.data.zWidth = _kwargs.zWidth

        manager.resource:loadASYNC(self.data.music, function (_resourse)
            if self.active then
                manager.sound:setMusic(_resourse, true)
            end
        end)
    end

    function scene:push()
        self.active = true
        manager.sound:setMusic(manager.resource:get(self.data.music), true)
        manager.render:addLayer(self.data.layer, {
            background = self.data.background,
            camera = self.data.camera,
            height = self.data.height,
            width = self.data.width,
            z = self.data.zWidth
        })
        manager.render:addLayer("debug")
    end

    function scene:pop()
        self.active = false
        manager.sound:pauseMusic()
        manager.render:removeLayer(self.data.layer)
    end

    function scene:updateBackground()
        --log:info("i'm sleep")
    end

    function scene:recovery()
        self:push()
    end

return scene
