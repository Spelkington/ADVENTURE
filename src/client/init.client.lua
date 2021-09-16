local SideCamera = require(script.SideCamera)
local PlayerController = require(script.PlayerController)
local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer

RunService.RenderStepped:Connect(SideCamera.set)
local sceneChangedEvent: RemoteEvent = player:WaitForChild("SceneChanged")

sceneChangedEvent.OnClientEvent:Connect(SideCamera.setCameraAttributes)

print("Creating player controls...")
PlayerController.start()