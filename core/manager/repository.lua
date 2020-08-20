local core = require(string.match(...,"(.*[%.]?core).+"))
assert( core and core._VERSION >= 1.0, "The core was not found, or its version is not supported")

local log = core:require("log")

local localRepository = { }

local repository = {}

    function repository:init()
        log:success("Repository manager initialized!")
    end

    function repository:create( _repositoryName )
        localRepository[_repositoryName] = localRepository[_repositoryName] or { }
        log:success("Repository created!")
    end

    function repository:add( _repositoryName, _id, _data )
        if not (_id and _data) then return end
        if not localRepository[_repositoryName] then return end
        localRepository[_repositoryName] = localRepository[_repositoryName] or { }
        localRepository[_repositoryName][_id] = _data
    end

    function repository:remove( _repositoryName, _id )
        if not localRepository[_repositoryName] then return end
        localRepository[_repositoryName][_id] = nil
    end

    function repository:get( _repositoryName, _id )
        return localRepository[_repositoryName] and localRepository[_repositoryName][_id] or nil
    end

return repository