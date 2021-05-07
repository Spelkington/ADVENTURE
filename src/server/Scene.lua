local Scene = {}
Scene.__index = Scene

local SCENE_DEBOUNCE_TIME = 0.3

function Scene.new(sceneModel: Model)

    local _Scene = {}
    setmetatable(_Scene, Scene)
    _Scene.model = sceneModel

    _Scene:setup()
    _Scene:createConnections()

    print("Scene " .. _Scene.model.Name .. " loaded!")

end

function Scene:setup()

    self.panel = self.model.Panel
    self.panel.Orientation = Vector3.new(0,0,0)

end

function Scene:createConnections()

    self.panel.Touched:Connect(function(touched) self:onPanelTouched(touched) end)

end

function Scene:onPanelTouched(touched)

    local player = game.Players:GetPlayerFromCharacter(touched.Parent)
    if player then

        local sceneTracker   = player.CurrentScene
        local sceneDebounce  = player.SceneDebounce

        if sceneDebounce.Value ~= true and sceneTracker.Value ~= self.model then

            print("Player" .. player.Name .. " has entered scene " .. self.model.Name)
            sceneDebounce.Value = true

            sceneTracker.Value = self.model
            
            wait(SCENE_DEBOUNCE_TIME)
            sceneDebounce.Value = false

        end

    end

end

-- STATIC METHODS

function Scene.addPlayerSignals(player)

    -- Create scene value in player
    local sceneTracker = Instance.new("ObjectValue")
    sceneTracker.Name = "CurrentScene"
    sceneTracker.Parent = player
    sceneTracker.Value  = nil

    -- Add scene debounce in player
    local sceneDebounce = Instance.new("BoolValue")
    sceneDebounce.Name = "SceneDebounce"
    sceneDebounce.Parent = player
    sceneDebounce.Value = false

    -- Add player camera distance
    local cameraDistance = Instance.new("IntValue")
    cameraDistance.Name = "SceneCameraDistance"
    cameraDistance.Parent = player
    cameraDistance.Value = 10

    -- Add player camera margin
    local cameraMargin = Instance.new("Vector3Value")
    cameraMargin.Name = "SceneCameraViewfield"
    cameraMargin.Parent = player
    cameraMargin.Value = Vector3.new(0,0,0)

    -- Add scene change remote event
    local sceneChangeEvent: RemoteEvent = Instance.new("RemoteEvent")
    sceneChangeEvent.Name = "SceneChanged"
    sceneChangeEvent.Parent = player

    -- Fire event to server and client on scene change
    sceneTracker:GetPropertyChangedSignal("Value"):Connect(function()
        sceneChangeEvent:FireClient(player)
    end)

    print(player.Name .. " prepped for scenes!")

end

return Scene