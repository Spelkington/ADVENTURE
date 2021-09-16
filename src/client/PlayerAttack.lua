local PlayerAttack = {}
local PLAYER = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MOVE_DIR = Vector3.new(10000, 0, 0)

local ATTACK_SPEED = 4
local ATTACK_THROUGH = 0.1
local ATTACK_DEBUFF_TIME = 0.3

local GRIP_ANGLE = 1.2 * math.pi

local ANIMATIONS = {}

function PlayerAttack.sideAttack(startDirection, endDirection)

    local weapon: Model = PLAYER.Character:FindFirstChild("Weapon")
    local humanoid = PLAYER.Character:WaitForChild("Humanoid")
    local animator: Animator = humanoid:WaitForChild("Animator")

    if weapon then

        if not ANIMATIONS["SideAttack"] then
            ANIMATIONS["SideAttack"] = animator:LoadAnimation(weapon.Animations.SideAttack)
        end
        local animation = ANIMATIONS["SideAttack"]

        local handle = weapon.Handle
        local weld = handle.AccessoryWeld
        local hand = weapon.Parent:FindFirstChild("RightHand")
        local torso = weapon.Parent:FindFirstChild("UpperTorso")

        local originalC0 = nil
        local originalC1 = nil

        if hand then
            originalC0 = weld.C0
            originalC1 = weld.C1
            weld.Part1 = hand

            weld.C1 = weld.C1 * CFrame.fromOrientation(GRIP_ANGLE, 0, 0)
        end
        
        PLAYER:Move(startDirection * MOVE_DIR)
        animation:Play(0.1, 1, ATTACK_SPEED)

        wait(animation.Length / ATTACK_SPEED + ATTACK_THROUGH)

        PLAYER:Move(endDirection * MOVE_DIR)
        wait(ATTACK_DEBUFF_TIME)

        if torso then
            weld.C0 = originalC0
            weld.C1 = originalC1
            weld.Part1 = torso
        end

    end

end

function PlayerAttack.highAttack(animation)

end

function PlayerAttack.lowAttack(animation)

end

return PlayerAttack