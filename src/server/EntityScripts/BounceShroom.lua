local BaseEntity = require(game.ServerScriptService.Server.BaseEntity)

local BounceShroom = {}
BounceShroom.__index = BounceShroom
setmetatable(BounceShroom, BaseEntity)

local USERCONTROL_VELOCITY = 0
local LAUNCH_TIME = 0.1
local FALLCHECK_TIME = 0.5
local DEBOUNCE_TIME = 1
local DIVE_TILT = -45

local TIERS = {
    80,
    130,
    160,
    300
}

function BounceShroom.new(entityBlock: BasePart)

    local _BounceShroom = BaseEntity.new(entityBlock)
    setmetatable(_BounceShroom, BounceShroom)

    _BounceShroom:setup()

    return _BounceShroom

end

function BounceShroom:setup()

    self.debounce = {}

    -- Describe OnTouch behavior
    self.button = self.model.EntityBox
    self.button.Touched:connect(function(touched) 
        local humanoid = touched.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local entity: Model = touched.Parent

            if not self.debounce[entity.Name]
               and entity.HumanoidRootPart.Position.Y > self.button.position.Y
               then
                self.debounce[entity.Name] = true

                print(entity.Name .. " touched a mushroom!")
                self:launch(entity)

                wait(DEBOUNCE_TIME)
                self.debounce[entity.Name] = false
            end

        end
    end)

    -- Assign tier attributes
    self:setTier()

    print("BounceShroom set up!")

end

function BounceShroom:setTier()

    if self.config:FindFirstChild("Tier") then
        self.tier = self.config.Tier.Value
    else
        for i, val in pairs(TIERS) do
            if self.config.Velocity.Value < val then
                self.tier = math.max(1, i - 1)
                break
            end
        end
    end

    if not self.tier then
        return
    end

    local tierBlock = game.ServerStorage.Entities[self.model.Name].Tiers:FindFirstChild(self.tier)
    if tierBlock then
        for _, block: BasePart in pairs(self.model.Head:GetChildren()) do
            block.Material = tierBlock.Material
            block.Transparency = tierBlock.Transparency
            block.Reflectance = tierBlock.Reflectance
            block.Color = tierBlock.Color
        end
    end

end

function BounceShroom:launch(character: Model)

    local torso: BasePart = character.HumanoidRootPart
    local upVector = self.button.CFrame.UpVector
    local velocity = self.config.Velocity.Value
    local diveDirection = 0
    if upVector.X > 0 then
        diveDirection = 180 + DIVE_TILT * 2
    end

    character.Humanoid.Sit = true

    torso.CFrame = self.button.CFrame
                 * CFrame.Angles(0, math.rad(90 - DIVE_TILT + diveDirection), 0)
                 + upVector * 3

    local launchForce: BodyVelocity = Instance.new("BodyVelocity")
    launchForce.Parent = torso
    launchForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    launchForce.Velocity = upVector * velocity

    wait(LAUNCH_TIME)
    launchForce:Destroy()

    wait(FALLCHECK_TIME)
    while torso.AssemblyLinearVelocity.Y > USERCONTROL_VELOCITY do
        wait()
    end

    character.Humanoid.Sit = false

    return

end

return BounceShroom