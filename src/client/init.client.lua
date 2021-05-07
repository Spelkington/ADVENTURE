local SideCamera = require(script.SideCamera)

local player = game.Players.LocalPlayer

game:GetService("RunService").RenderStepped:Connect(SideCamera.set)
local sceneChangedEvent: RemoteEvent = player:WaitForChild("SceneChanged")
sceneChangedEvent.OnClientEvent:Connect(SideCamera.setCameraAttributes)