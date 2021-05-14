local ExtraUtils = require(game.ServerScriptService.Server.ExtraUtils)
local BaseEntity = require(game.ServerScriptService.Server.BaseEntity)

local Scene = {}
Scene.__index = Scene

local SCENE_DEBOUNCE_TIME = 0.5
local ROOT_SCENE_POSITION = Vector3.new(0, 500, 0)
local BASE_COLOR    = BrickColor.new(Color3.new(163, 162, 165))
local SURFACE_COLOR = BrickColor.new(Color3.new(  0, 255,   0))
local CEILING_COLOR = BrickColor.new(Color3.new(  0,   0,   0))

local SURFACE_OVERHANG = 1
local SURFACE_THICKNESS = 2
local SURFACE_TOPLAYER = 0.1

function Scene.new(sceneModel: Model)

    local _Scene = {}
    setmetatable(_Scene, Scene)
    _Scene.model = sceneModel:Clone()

    _Scene:setup()
    _Scene:createConnections()

    return _Scene

end

function Scene:setup()

    -- Move model into Server Storage

    self.panel = self.model.Panel
    self.config = self.model.Scene

    -- Do initial pre-workspace orientation
    self.model.PrimaryPart = self.panel
    self.model:SetPrimaryPartCFrame(CFrame.new(
        self.panel.Position
    ))
    self.panel.Transparency = 1

    -- Track scene connections
    self.paths = {}
    local pathBlocks = self.model:FindFirstChild("ScenePaths")
    if pathBlocks then
        for _, path: BasePart in pairs(pathBlocks:GetChildren()) do
            self.paths[path.Name] = path
        end
    end

    -- Find surface parts
    self.surfaces = {}
    self.ceilings = {}

    local originalSceneParent = self.model.Parent
    self.model.Parent = game.Workspace

    local s_i = 1
    local c_i = 1
    for _, ancestor in pairs(self.model.Skeleton:GetDescendants()) do
        if ancestor:IsA("BasePart") then
            if ExtraUtils.compareColors(ancestor.Color, SURFACE_COLOR) then
                self.surfaces[s_i] = ancestor
                s_i += 1
            elseif ExtraUtils.compareColors(ancestor.Color, CEILING_COLOR) then
                self.ceilings[c_i] = ancestor
                c_i += 1
            end
        end
    end

    -- Track biome
    self.biome = game.ReplicatedStorage.Biomes:FindFirstChild(self.config.Biome.Value)
	if not self.biome then print("WARNING: Biome for scene " .. self.model.Name .. " could not be loaded!") end
    self:applyBiome()

    self:loadEntities()

    self.model.Parent = originalSceneParent

end

function Scene:applyBiome()

    -- Create a decor directory if it's not already available
    if not self.decor then
        self.decor = Instance.new("Model")
        self.decor.Name = "Decor"
        self.decor.Parent = self.model
    end

    local base:    BasePart = self.biome.Blocks.Base
    local surface: BasePart = self.biome.Blocks.Surface

    -- Set all block types to biome type
    for _, block: BasePart in pairs(self.model.Skeleton:GetDescendants()) do
        if block:IsA("BasePart") then
            block.Transparency = base.Transparency
            block.Color        = base.Color
            block.Material     = base.Material
        end
    end

    for _, block: BasePart in pairs(self.surfaces) do
        local surfaceBlock = Scene._addSurface(block)

        if surfaceBlock then
            surfaceBlock.Parent = self.decor
            surfaceBlock.Name = "Surface"
            surfaceBlock.Color = surface.Color
            surfaceBlock.Transparency = surface.Transparency
            surfaceBlock.Material = surface.Material
            surfaceBlock.CanCollide = false
        else
            print("Surface was not generated for:")
            print(block)
        end

    end

end

function Scene:loadEntities()

    self.entities = {}

    local entitiesContainer: Model = self.model:FindFirstChild("Entities")
    local entitiesScripts = BaseEntity.loadEntityBehaviors()

    if entitiesContainer then

        for i, e in ipairs(entitiesContainer:GetChildren()) do
            local EntityModule = entitiesScripts[e.Name]
            self.entities[i] = EntityModule.new(e)
        end

    end

end

function Scene._addSurface(block)

    local result = nil

    if block:IsA("WedgePart") then

        local origin = block.Position
                        + block.CFrame.LookVector
                        * (block.Size.Z/2)

        local lookAt = (block.Position - origin).Unit
                        * block.Size.Z

        local castResult: RaycastResult = workspace:Raycast(origin, lookAt)

        if castResult then

            local hitPart   = castResult.Instance
            local hitPos    = castResult.Position
            local hitNormal = castResult.Normal

            if hitPart == block then
                result = Instance.new("Part")
                result.Anchored = true

                local length = Vector2.new(
                    block.Size.Z,
                    block.Size.Y
                ).Magnitude

                result.Size = Vector3.new(
                    block.Size.X + SURFACE_OVERHANG * 2,
                    length       + SURFACE_TOPLAYER * 2,
                    SURFACE_THICKNESS
                )

                local lift = -1 * result.Size.Z / 2 + SURFACE_TOPLAYER

                result.CFrame = CFrame.new(
                    hitPos + hitNormal * lift,
                    hitPos + hitNormal * 10000
                )

            end
        
        end

    else

        result = Instance.new("Part")
        result.Anchored = true

        local globalSize = ExtraUtils.getGlobalSize(block)

        result.Size = Vector3.new(
            globalSize.X + SURFACE_TOPLAYER * 2,
            SURFACE_THICKNESS,
            globalSize.Z + SURFACE_OVERHANG * 2
        )

        local height = block.Position.Y + globalSize.Y/2
                     - result.Size.Y / 2 + SURFACE_TOPLAYER

        result.CFrame = CFrame.new(
            block.Position.X,
            height,
            block.Position.Z
        )
        
    end

    return result
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

function Scene.stitchScenes(sceneTable)

    local sceneContainer = Instance.new("Model")
    sceneContainer.Name = "Scenes"
    sceneContainer.Parent = game.Workspace

    local first = sceneTable[next(sceneTable)]
    Scene._stitchScene(first, nil, sceneTable)

    for _, scene in pairs(sceneTable) do
        for pathName, pathBlock in pairs(scene.paths) do
            pathBlock.Transparency = 1
        end
    end

end

function Scene._stitchScene(target, caller, sceneTable)

    local sceneContainer = game.Workspace.Scenes
    
    print("Stitching " .. target.model.Name .. "...")

    if not caller then
        -- if scene is first loaded, just spawn it at the default position
        target.model.PrimaryPart = target.panel
        target.model.Parent = sceneContainer
        target.model:MoveTo(ROOT_SCENE_POSITION)

    else

        local callStitch: BasePart = caller.paths[target.model.Name]
        local targStitch: BasePart = target.paths[caller.model.Name]

        target.model.PrimaryPart = targStitch
        target.model.Parent = sceneContainer
        target.model:SetPrimaryPartCFrame(
            CFrame.new(callStitch.Position)
          * CFrame.Angles(
              math.rad(targStitch.Orientation.X),
              math.rad(targStitch.Orientation.Y),
              math.rad(targStitch.Orientation.Z)
            )
        )
        
    end

    for pathName, pathBlock in pairs(target.paths) do
        local nextTarg = sceneTable[pathName]
        if nextTarg then
            local loaded = sceneContainer:FindFirstChild(nextTarg.model.Name)
            if not loaded then
                Scene._stitchScene(nextTarg, target, sceneTable)
            end

            pathBlock.CanCollide = false
        else
            -- If the next scene doesn't exist, block it off
            pathBlock.CanCollide = true
        end
    end

end

return Scene