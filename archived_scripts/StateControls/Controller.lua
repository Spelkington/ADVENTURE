local StateMachine = require(game.ReplicatedStorage.Common.StateMachine)
local ContextActionService: ContextActionService = game:GetService("ContextActionService")

local Controller = {}
Controller.__index = Controller

local PLAYER: Player = game.Players.LocalPlayer
local CHARACTER: Model = PLAYER.Character

function Controller.new(connections, buttons)

    local _Controller = {}
    setmetatable(_Controller, Controller)

    _Controller.stateFolder = Instance.new("Folder", PLAYER)
    _Controller.stateFolder.Name = "ControlStates"

    local currentState = Instance.new("StringValue", _Controller.stateFolder)
    currentState.Name = "Current"

    local previousState = Instance.new("StringValue", _Controller.stateFolder)
    previousState.Name = "Previous"

    -- _Controller.machine = StateMachine.new(connections, _Controller.stateFolder)
    _Controller.machine:setState("IDLE")
    _Controller:connectButtons(buttons)

    return _Controller

end

function Controller:connectButtons(buttonTable)

    for action, buttons in pairs(buttonTable) do
        ContextActionService:BindAction(
            action,
            function()
                self.machine:sendAction(action)
            end,
            false,
            unpack(buttons)
        )
    end

end

return Controller