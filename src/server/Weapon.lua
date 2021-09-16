local Weapon = {}
Weapon.__index = Weapon

local ServerStorage = game:GetService("ServerStorage")
local WeaponStorage = ServerStorage.Weapons

local DEFAULT_WEAPON = WeaponStorage.Sword

function Weapon.new(model, character)
    local _Weapon = {}
    setmetatable(_Weapon, Weapon)
    
    _Weapon.model = model:Clone()
    _Weapon.owner = character

    _Weapon:setup()

    return _Weapon
end

function Weapon:setup()
    print(self.owner.Name .. "'s " .. self.model.Name .. " loading!")

    self.model.Parent = self.owner
    self.model.Name = "Weapon"
    self.handle = self.model:FindFirstChild("Handle")

    self:constructBlade()
    -- self:loadAnimations()

end

function Weapon:constructBlade()

    self.blades = {}
    for _, inst: Instance in pairs(self.model:GetDescendants()) do
        if inst:IsA("BasePart") then

            local weaponPart: BasePart = inst
            weaponPart.CanCollide = false
            weaponPart.Massless = true

            if inst ~= self.handle then

                local weld: Weld = Instance.new("Weld", weaponPart)
                weld.Part0 = self.handle
                weld.Part1 = weaponPart
                
                weld.C0 = self.handle.CFrame:Inverse()
                weld.C1 = weaponPart.CFrame:Inverse()

                if inst.Name == "Blade" then
                    self.blades[#self.blades] = inst
                end

            end

        end
    end

end

function Weapon:loadAnimations()

    local animations = self.model.Animations
    local humanoid = self.owner:WaitForChild("Humanoid")
    local animator: Animator = humanoid:WaitForChild("Animator")

    self.owner.AncestryChanged:wait()

    for _, animation in pairs(animations:GetChildren()) do
        animator:LoadAnimation(animation)
    end

end

-- STATIC FUNCTIONS

function Weapon.givePlayerWeapon(player)
    local character = player.Character
    
    if character then
        Weapon.new(DEFAULT_WEAPON, character)
    end
    
end

return Weapon