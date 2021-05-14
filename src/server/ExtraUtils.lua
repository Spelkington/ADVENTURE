local ExtraUtils = {}

function ExtraUtils.compareColors(lhs: BrickColor, rhs: BrickColor)

	local epsilon = 0.001
	if math.abs(lhs.r - rhs.r) > epsilon then
		return false
	end

	if math.abs(lhs.g - rhs.g) > epsilon then
		return false
	end

	if math.abs(lhs.b - rhs.b) > epsilon then
		return false
	end

	return true
end

function ExtraUtils.getGlobalSize(block: BasePart)
	local globalSize = block.CFrame:VectorToWorldSpace(block.Size)
	globalSize = Vector3.new(
		math.abs(globalSize.X),
		math.abs(globalSize.Y),
		math.abs(globalSize.Z)
	)
	return globalSize
end

function ExtraUtils.setGlobalSize(block: BasePart, newSize: Vector3)
	local objectSize = block.CFrame:VectorToObjectSpace(newSize)
	objectSize = Vector3.new(
		math.abs(objectSize.X),
		math.abs(objectSize.Y),
		math.abs(objectSize.Z)
	)
	block.Size = objectSize
	return
end



return ExtraUtils