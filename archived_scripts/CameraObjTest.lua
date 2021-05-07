local SideCamera = {}
SideCamera.__index = SideCamera

local CAMERA_HEIGHT   = 12
local CAMERA_Z_OFFSET = 20
local CAMERA_X_CHASE  = 10
local CAMERA_SPEED    = .25

function SideCamera.init(player, cameraHeight, cameraZOffset, cameraXChase, cameraSpeed)

    -- Instantiate metatable for new object
    local _SideCamera = {}
    setmetatable(_SideCamera, SideCamera)

    -- Store instance variables
    _SideCamera.cameraHeight  = cameraHeight
    _SideCamera.cameraZOffset = cameraZOffset
    _SideCamera.cameraXChase  = cameraXChase
    _SideCamera.cameraSpeed   = cameraSpeed

    -- Create new instance variables
    _SideCamera.currentCam = game.Workspace.CurrentCamera

    -- Return error if a player wasn't provided
    if not player then error("New Camera object was missing player.") end
    _SideCamera.player = player

    -- Cast missing values to default
    if not _SideCamera.cameraHeight  then _SideCamera.cameraHeight  = CAMERA_HEIGHT   end
    if not _SideCamera.cameraZOffset then _SideCamera.cameraZOffset = CAMERA_Z_OFFSET end
    if not _SideCamera.cameraXChase  then _SideCamera.cameraXChase  = CAMERA_X_CHASE  end
    if not _SideCamera.cameraSpeed   then _SideCamera.cameraSpeed   = CAMERA_SPEED    end

    _SideCamera:reset()

    return _SideCamera

end

function SideCamera:reset()

	self.currentCam.CFrame = CFrame.new(
        Vector3.new(
            0,
            self.cameraHeight,
            self.cameraZOffset
        ),
		Vector3.new(
            0,
            self.cameraHeight,
            0
        )
    )
end

function SideCamera:onUpdate()

	if self.player.Character and self.player.Character:FindFirstChild('HumanoidRootPart') then
		local playerX = self.player.Character.HumanoidRootPart.Position.X
		local cameraX = self.currentCam.CFrame.p.X
		
		if cameraX - self.cameraXChase < playerX then
			self.currentCam.CFrame = self.currentCam.CFrame + Vector3.new(self.cameraSpeed, 0, 0)
		end
	end

end

return SideCamera