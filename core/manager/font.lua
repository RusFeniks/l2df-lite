local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")
assert( love, "This manager require love2d framework to stable working")

local log = core:require("log")
local help = core:require("help")
local fs = love and love.filesystem
local parser = core:require("parser")

local newFont = love.graphics.newFont
local newImageFont = love.graphics.newImageFont
local getFileExtension = help.getFileExtension

local fontCache = { }
local defaultFont = newFont(16)

local function loadImageFont(filePath)
    return newImageFont(filePath, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
end

local function loadTrueTypeFont(filePath, size)
    return newFont(filePath, size or 16)
end

local formats = {
    [".png"] = { processing = loadImageFont },
    [".ttf"] = { processing = loadTrueTypeFont },
    [".otf"] = { processing = loadTrueTypeFont }
}


local font = {}

    function font:init()
        log:success("Font manager initialized!")
    end


    function font:cache(name, filePath, size)
        if not fs.getInfo(filePath) then return end
        local ext = getFileExtension(filePath)
        fontCache[name] = formats[ext].processing(filePath, size)
        log:success("Font loaded:", name, filePath, size)
    end


    function font:preload(filePath)
        if not fs.getInfo(filePath) then return end
        local fonts = parser:parse(fs.read(filePath)).fonts
        if not fonts or #fonts < 1 then return end
        local f
        for i = 1, #fonts do
            f = fonts[i]
            font:cache(f[1], f.file, f.size)
        end
    end

    function font:get(name)
        return (name and fontCache[name]) or defaultFont
    end


return font