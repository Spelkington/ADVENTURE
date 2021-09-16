local SideCamera = {}

local camera: Camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer

local originalCFrame = camera.CFrame
local originalFocus = camera.Focus
local originalType = camera.CameraType

local cameraFree = true

camera.CameraType = Enum.CameraType.Custom

local CAMERA_PLACEMENT = Vector3.new(0, 0, 1)

function SideCamera.set()

	if player:FindFirstChild("CurrentScene") then

		local scene = player.CurrentScene.Value
		local character = player.Character

		if character and character:FindFirstChild("HumanoidRootPart") then
			if scene then

				cameraFree = false

				local panel: Part = scene.Panel

				local cameraDistance  = player.SceneCameraDistance.Value
				local cameraViewfield = player.SceneCameraViewfield.Value

				local xBounds = {}
				xBounds["min"] = panel.Position.X - panel.Size.X / 2 + cameraViewfield.X / 2
				xBounds["max"] = panel.Position.X + panel.Size.X / 2 - cameraViewfield.X / 2

				local yBounds = {}
				yBounds["min"] = panel.Position.Y - panel.Size.Y / 2 + cameraViewfield.Y / 2
				yBounds["max"] = panel.Position.Y + panel.Size.Y / 2 - cameraViewfield.Y / 2

				local torso = character.HumanoidRootPart

				local camPosX = torso.Position.X
				local camPosY = torso.Position.Y

				if xBounds["min"] < xBounds["max"] then						
					camPosX = math.max(xBounds.min, torso.Position.X)
					camPosX = math.min(xBounds.max, camPosX)
				else
					camPosX = panel.Position.X
				end

				if yBounds["min"] < yBounds["max"] then						
					camPosY = math.max(yBounds.min, torso.Position.Y)
					camPosY = math.min(yBounds.max, camPosY)
				else
					camPosY = panel.Position.Y
				end

				local cameraPosition = Vector3.new(
					camPosX,
					camPosY,
					panel.Position.Z
				)

				-- Adjusts focus for performance
				camera.Focus = panel.CFrame

				camera.CFrame = CFrame.new(
					cameraPosition + (CAMERA_PLACEMENT * cameraDistance),
					cameraPosition
				)

				-- Fix torso position to Z = 0
				-- This possibly doesn't fit in the camera script,
				-- but it sure is convenient!
				local zdiff = panel.Position.Z - torso.Position.Z
				torso.CFrame = torso.CFrame + Vector3.new(0, 0, zdiff)

			elseif not cameraFree then

				camera.CameraType = Enum.CameraType.Custom
				camera.CameraSubject = character.Humanoid
				cameraFree = true

			end

		end

	end

end

function SideCamera.setCameraAttributes()

	local scene = player.CurrentScene.Value
	local cameraDistance = player.SceneCameraDistance
	local cameraViewfield = player.SceneCameraViewfield

	if scene then

		local panel: Part = scene.Panel

		local aspectRatio = camera.ViewportSize.X / camera.ViewportSize.Y

		local horizFOV = math.rad(camera.MaxAxisFieldOfView)

		local width = panel.size.X
		if scene.Scene:FindFirstChild("ForceCameraProportion") then
			width *= scene.Scene.ForceCameraProportion.Value
		end

		local angleCoef = 1 / (2 * math.tan(horizFOV / 2))

		local dist = width * angleCoef
		cameraDistance.Value  = dist
		cameraViewfield.Value = Vector3.new(
			width,
			width / aspectRatio,
			0
		)


		print("Screen Dims:", camera.ViewportSize.X, camera.ViewportSize.Y)
		print("theta_v", math.tan(camera.FieldOfView))
		print("theta_h: ", horizFOV)
		print("angleCoef", angleCoef)
		print("Width: ", width)
		print("New camera distance set: ", cameraDistance.Value)
		print("Camera viewpoint in blocks: ", cameraViewfield.Value)

	end

end

return SideCamera