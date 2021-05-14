local Entity = {}
Entity.__index = Entity

local SCRIPT_DIR = game.ServerScriptService.Server.EntityScripts
local ENTITY_DIR = game.ServerStorage.Entities

function Entity.new(entityBlock: BasePart)

    local _Entity = {}
    setmetatable(_Entity, Entity)

    _Entity.model = ENTITY_DIR:FindFirstChild(entityBlock.Name).Model:Clone()
    _Entity.model.Name = entityBlock.Name
    _Entity.model.Parent  = entityBlock.Parent
    
    _Entity.config = entityBlock.EntityConfig:Clone()
    _Entity.config.Parent = _Entity.model

    _Entity.model:SetPrimaryPartCFrame(entityBlock.CFrame)

    entityBlock:Destroy()

    return _Entity

end

function Entity.loadEntityBehaviors()

    local entities = {}
    for _, entityScript in pairs(SCRIPT_DIR:GetChildren()) do
        entities[entityScript.Name] = require(entityScript)
    end
    return entities

end

return Entity