local PlayerController = {}
local PLAYER: Player = game.Players.LocalPlayer

local ContextActionService: ContextActionService = game:GetService("ContextActionService")

local PlayerMovement = require(script.Parent.PlayerMovement)

local ANIMATIONS = {}

local BUTTON_ACTIONS = {
    JUMP = {Enum.KeyCode.W, Enum.KeyCode.Space},
    FALL = {Enum.KeyCode.S},
    WALK_RIGHT = {Enum.KeyCode.D},
    WALK_LEFT  = {Enum.KeyCode.A},
    ATTACK_LEFT = {Enum.KeyCode.Left},
    ATTACK_RIGHT = {Enum.KeyCode.Right},
}

local FUNC_BINDINGS = {
    JUMP = PlayerMovement.jump,
    FALL = PlayerMovement.fall,
    WALK_RIGHT   = PlayerMovement.walk,
    WALK_LEFT    = PlayerMovement.walk,
    ATTACK_LEFT  = PlayerMovement.attack,
    ATTACK_RIGHT = PlayerMovement.attack,
}

function PlayerController.bind(bindings)

    for action, func in pairs(bindings) do

        ContextActionService:BindAction(
            action,
            func,
            false,
            unpack(BUTTON_ACTIONS[action])
        )

    end
end


function PlayerController.start()
    PlayerController.bind(FUNC_BINDINGS)
end

return PlayerController