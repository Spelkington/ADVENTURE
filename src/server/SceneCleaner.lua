local SceneCleaner = {}
SceneCleaner.__index = SceneCleaner

function SceneCleaner.new(part)

    local _SceneCleaner = {}
    setmetatable(_SceneCleaner, SceneCleaner)

    _SceneCleaner.part = part

    _SceneCleaner:setup()

    return _SceneCleaner

end

function SceneCleaner:setup()

    self.part.Touched:Connect(function(touched)
        local player = game.Players:GetPlayerFromCharacter(touched.Parent)
        if player then
            player.CurrentScene.Value = nil
            print(player.Name .. " scene removed!")
        end
    end)

end

return SceneCleaner