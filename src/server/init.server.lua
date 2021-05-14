

-- SCENE SCRIPTS ----------

local Scene = require(game.ServerScriptService.Server.Scene)

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