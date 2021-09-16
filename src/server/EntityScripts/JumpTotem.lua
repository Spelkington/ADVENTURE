local BaseEntity = require(game.ServerScriptService.Server.BaseEntity)

local JumpTotem = {}
JumpTotem.__index = JumpTotem
setmetatable(JumpTotem, BaseEntity)

local JUMP_MODIFIER = 1.1
local DIST_MODIFIER = 1.4

function JumpTotem.new(entityBlock: BasePart)

    local _JumpTotem = BaseEntity.new(entityBlock)
    setmetatable(_JumpTotem, JumpTotem)

    _JumpTotem:setup()

    return _JumpTotem

end

function JumpTotem:setup()

    self.button = self.model.Base

    self.button.Touched:Connect(function(touched)

        local humanoid: Humanoid = touched.Parent:FindFirstChild("Humanoid")

        if humanoid then
            local jumpHeight = humanoid.jumpHeight * JUMP_MODIFIER
            local jumpTime = JumpTotem._getJumpTime(jumpHeight)
            local jumpDistance = jumpTime
                               * humanoid.WalkSpeed
                               * DIST_MODIFIER

            if self.display then
                self.display:Destroy()
            end

            self.display = Instance.new("Part")
            self.display.Anchored   = true
            self.display.CanCollide = false
            self.display.Transparency = 0.8
            self.display.Color = Color3.new(0, 255, 0)

            self.display.Size = Vector3.new(
                jumpDistance * 2,
                jumpHeight,
                1
            )

            self.display.Position = self.button.Position + Vector3.new(
                0,
                self.display.Size.Y / 2,
                0
            )

            self.display.Parent = self.model

        end
        
    end)

end

function JumpTotem._getJumpTime(jumpHeight: number)

    local gravity = game.Workspace.Gravity
    local time = 2 * math.sqrt(jumpHeight / gravity)

    return time

end

return JumpTotem