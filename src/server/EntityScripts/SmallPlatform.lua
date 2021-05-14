local BaseEntity = require(game.ServerScriptService.Server.BaseEntity)

local SmallPlatform = {}
SmallPlatform.__index = SmallPlatform
setmetatable(SmallPlatform, BaseEntity)

function SmallPlatform.new(entityBlock: BasePart)

    local _SmallPlatform = BaseEntity.new(entityBlock)
    setmetatable(_SmallPlatform, SmallPlatform)

    _SmallPlatform:setup()

    return _SmallPlatform

end

function SmallPlatform:setup()

end

return SmallPlatform