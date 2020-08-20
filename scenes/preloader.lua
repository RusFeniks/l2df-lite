local log = L2DF:require("log")

local behaviour = L2DF:require("class.component.behaviour")
local scenes = L2DF:require("manager.scene")
local repository = L2DF:require("manager.repository")
local resource = L2DF:require("manager.resource")

local loader = L2DF:require("loader")


local scene = L2DF:initScene([[
    background: 100 100 100 100
    --music: "res/bg.mp3"

    
    <node:image> logotype
        pic: 0 x: 0 y: 0
        <sprite>
            file: "res/Loading/1.png"
        </sprite>
    </node>

    <node:text>
        x: 200
        y: 200
        text: "FUFUFU"
    </text>

    <node:animation> loader
        x: 820 y: 400  frame: 1
        <sprite>
            file: "res/Loading/loading.png" w: 140 h: 140 x: 4 y: 3
        </sprite>
        
        <frame> 1
            pic: 1 next: 2 wait: 2
        </frame>    
        <frame> 2
            pic: 2 next: 3 wait: 2
        </frame>    
        <frame> 3
            pic: 3 next: 4 wait: 2
        </frame>    
        <frame> 4
            pic: 4 next: 5 wait: 2
        </frame>    
        <frame> 5
            pic: 5 next: 6 wait: 2
        </frame>    
        <frame> 6
            pic: 6 next: 7 wait: 2
        </frame>    
        <frame> 7
            pic: 7 next: 8 wait: 2
        </frame>    
        <frame> 8
            pic: 8 next: 9 wait: 2
        </frame>    
        <frame> 9
            pic: 9 next: 10 wait: 2
        </frame>    
        <frame> 10
            pic: 10 next: 11 wait: 2
        </frame>    
        <frame> 11
            pic: 11 next: 12 wait: 2
        </frame>    
        <frame> 12
            pic: 12 next: 1 wait: 2
        </frame>
    </node>
]])

local _push = scene.push
function scene:push()
    _push(self)

    repository:create("state")
    for _fileName, _fileData in loader:requireDirectory( "data/states" ) do
        repository:add("state", _fileName, _fileData)
        log:success("- state loaded:", _fileName)
    end

    repository:create("kind")
    for _fileName, _fileData in loader:requireDirectory( "data/kinds" ) do
        repository:add("kind", _fileName, _fileData)
        log:success("- kind loaded:", _fileName)
    end

end

function scene:update()
    if not self.active then return end
    if not resource:checkTurn() then
        --scenes:set("main_menu")
    end
end

scene:addComponent(behaviour, {
    update = scene.update
})


return scene