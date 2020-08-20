local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")
assert( love, "This manager require love2d framework to stable working")

local log = core:require("log")
local help = core:require("help")

local play = love.audio.play

local sound = {}

    local music
    local music_volume, sound_volume = 0.1, 1
    local list = { }

    function sound:init( input )
        input = input or { }
        core:hook("update", function ( ... )
            play(list)
            list = { }
        end)
        music_volume = input.music or music_volume
        sound_volume = input.sound or sound_volume
        log:success("Sound manager initialized!")
    end

    function sound:setMusic(source, looping)
        if music and music.typeOf and music:typeOf("Source") then
            if music ~= source then
                music:stop()
            end
        end
        if not source then return end
        music = source
        music:setVolume(music_volume)
        music:setLooping(looping or false)
        music:play()
    end

    function sound:pauseMusic()
        if music and music.isPlaying and music:isPlaying() then
            music:pause()
        end
    end

    function sound:add(input)
        if not input
        or not input.resource
        or not input.resource.typeOf
        or not input.resource:typeOf("Source")
        then return end

        local sound = input.resource:clone()
        sound:setVolume((input.volume or 1) * sound_volume)

        list[#list + 1] = sound
    end

    function sound:setSoundVolume( val )
        sound_volume = val >= 0 and val <= 1 and val or sound_volume
    end

    function sound:setMusicVolume( val )
        music_volume = val >= 0 and val <= 1 and val or music_volume

        if not music
        or not music.typeOf
        or not music:typeOf("Source")
        then return end

        music:setVolume(music_volume)
    end

return sound
