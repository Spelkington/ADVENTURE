local SideCamera = {}

local camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer

camera.CameraType = Enum.CameraType.Scriptable

local TARGET_DISTANCE  = script.Configuration.TARGET_DISTANCE
local CAMERA_DISTANCE  = script.Configuration.CAMERA_DISTANCE
local CAMERA_DIRECTION = script.Configuration.CAMERA_DIRECTION
local FOCUS_ADJUST     = script.Configuration.FOCUS_ADJUST
local ORIGIN_ADJUST    = script.Configuration.ORIGIN_ADJUST

function SideCamera.set()

	local targetDistance  = TARGET_DISTANCE.Value
	local cameraDistance  = CAMERA_DISTANCE.Value
	local cameraDirection = CAMERA_DIRECTION.Value
	local focusAdjust     = FOCUS_ADJUST.Value
	local originAdjust    = ORIGIN_ADJUST.Value

	local currentTarget   = cameraDirection * targetDistance
	local currentPosition = cameraDirection * cameraDistance

	local character = player.Character

	if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then

		local torso = character.HumanoidRootPart

		camera.Focus = torso.CFrame

		camera.CoordinateFrame = CFrame.new(
			torso.Position + focusAdjust  + currentPosition,
			torso.Position + originAdjust + currentTarget
		)

	end

end

-- function SideCamera.connectConfig(config: Configuration)
--  
-- 	for _, child: ValueBase in pairs(config:GetChildren()) do
--  
-- 		child:GetPropertyChangedSignal("Value"):Connect(function()
-- 			print(child.Name .. " changed!")
-- 			SideCamera[child.Name] = child.Value
-- 		end)
--  
-- 	end	
-- end

return SideCamera