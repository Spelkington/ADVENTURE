local PlayerMovement = {}
local PLAYER = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local PlayerAttack = require(script.Parent.PlayerAttack)

local MOVE_DIR = Vector3.new(10000, 0, 0)

local JUMP_CANCEL_FRAMES = 12
local JUMP_STOP_MARGIN = 0.05
local JUMP_STOP_FORCE = 6500

local CURRENT_INPUT = {
    WALK_LEFT  = false,
    WALK_RIGHT = false,
    ATTACKING = false,
    JUMP = false,
}

local ANIMATIONS = {}

function PlayerMovement.walk(actionName, inputState, inputObject)

    local character = PLAYER.Character
    if not character then
        return
    end

    local activation = (inputState == Enum.UserInputState.Begin)
    CURRENT_INPUT[actionName] = activation

    local direction = 0
    if CURRENT_INPUT.WALK_LEFT then
        direction -= 1;
    end

    if CURRENT_INPUT.WALK_RIGHT then
        direction += 1;
    end

    PLAYER:Move(direction * MOVE_DIR)

    return Enum.ContextActionResult.Sink

end

function PlayerMovement.jump(actionName, inputState, inputObject)

    local character = PLAYER.Character

    if not character then
        return
    end

    if inputState == Enum.UserInputState.Begin then

        character.Humanoid.PlatformStand = false

        local fallState = CURRENT_INPUT.JUMP

        if not fallState then
            CURRENT_INPUT.JUMP = true
            character.Humanoid.Jump = true
            wait(JUMP_CANCEL_FRAMES * 0.016)
            CURRENT_INPUT.JUMP = false
        end

    else
        
        if CURRENT_INPUT.JUMP and character.HumanoidRootPart.AssemblyLinearVelocity.Y > 0 then
            local stopVelocity: BodyVelocity = Instance.new("BodyVelocity", character.HumanoidRootPart)
            stopVelocity.Velocity = Vector3.new(0, 0, 0)
            stopVelocity.MaxForce = Vector3.new(0, JUMP_STOP_FORCE, 0)
            
            repeat
                wait()
            until math.abs(character.HumanoidRootPart.AssemblyLinearVelocity.Y) < JUMP_STOP_MARGIN

            stopVelocity:Destroy()

        end

    end

end

function PlayerMovement.getFallState()

    local character = PLAYER.Character
    if not character then return end

    local state = character.Humanoid:GetState()

    return state == Enum.HumanoidStateType.Jumping
        or state == Enum.HumanoidStateType.Freefall
        or CURRENT_INPUT.JUMP

end

function PlayerMovement.fall(actionName, inputState, inputObject)
    print("fall!")
end

function PlayerMovement.attack(actionName, inputState, inputObject)

    if inputState == Enum.UserInputState.Begin
       and not CURRENT_INPUT["Attacking"] then

        CURRENT_INPUT["Attacking"] = true

        local startDirection = 0
        if actionName == "ATTACK_RIGHT" then
            startDirection = 1
        else
            startDirection = -1
        end

        local endDirection = 0
        if CURRENT_INPUT["WALK_RIGHT"] then
            endDirection = 1
        elseif CURRENT_INPUT["WALK_LEFT"] then
            endDirection = -1
        else
            endDirection = 0
        end

        PlayerAttack.sideAttack(startDirection, endDirection)

        CURRENT_INPUT["Attacking"] = false

    end

end

return PlayerMovement