local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")
local parser = core:require("parser")

local fs = love.filesystem

local function GetFileExtension(url)
    return url:match("^.+(%..+)$")
end

local function GetFileName(url)
    return url:match("^(.+)%..+$")
end

local function fixMissingSlash( _path )
    if string.sub(_path, -1) ~= "/" then
        return _path .. "/"
    end
    return _path
end

local loader = {}

    function loader:init()
        log:success("Loader module initialized!")
    end

    function loader:requireFile (_filePath)
        if fs.getInfo(_filePath) then
            if GetFileExtension(_filePath) == ".lua" then
                return GetFileName(_filePath), fs.load(_filePath)()
            end
        end
    end

    function loader:requireDirectory( _directoryPath )
        _directoryPath = fixMissingSlash(_directoryPath)
        if not fs.getInfo(_directoryPath) then 
            return function ()
                log:warn("Directory isn't exist!")
                return nil
            end
        end
        local _fileList = fs.getDirectoryItems(_directoryPath)
        local _i = 0
        return function ()
            while true do
                _i = _i + 1
                if _i > #_fileList then return nil end
                if GetFileExtension(_fileList[_i]) == ".lua" then
                    return GetFileName(_fileList[_i]), fs.load(_directoryPath .. _fileList[_i])()
                end
            end
        end
    end

return loader