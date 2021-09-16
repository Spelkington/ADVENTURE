local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

-- SCENE SCRIPTS ----------

local Scene = require(game.ServerScriptService.Server.Scene)
local Weapon = require(game.ServerScriptService.Server.Weapon)

-- Load models into server storage from Tinker workspace
_G.scenes = {}
for _, model:Model in pairs(game.Workspace:GetChildren()) do
    if model:FindFirstChild("Scene") then
        model.Parent = game.ServerStorage.Scenes
		_G.scenes[model.Name] = Scene.new(model)
    end
end

local scenes = _G.scenes
Scene.stitchScenes(scenes)

game.Players.PlayerAdded:Connect(Scene.addPlayerSignals)

if game.Workspace:FindFirstChild("Baseplate") then
    game.Workspace.Baseplate:Destroy()
end

-- Define player onAdded behavior
Players.PlayerAdded:Connect(function(player: Player)

    player.CharacterAdded:Connect(function(character: Character) 
        print(character.Name .. " spawned!")
        Weapon.givePlayerWeapon(player)
    end)

end)