--!strict
---- SERVICES ----
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

---- MODULES ----
local UserInputDevice = require(script.Parent.UserInputDevice)

---- PRIVATE VARIABLES ----
local Player = Players.LocalPlayer
local GuiFollowMouseScreenGui = Instance.new("ScreenGui")
GuiFollowMouseScreenGui.IgnoreGuiInset = true
GuiFollowMouseScreenGui.Name = "GuiFollowMouse"
GuiFollowMouseScreenGui.DisplayOrder = 100 -- So the GuiObjects always show at the top.
GuiFollowMouseScreenGui.Parent = Player.PlayerGui

local activeGuiObjects: {
	[GuiObject]: {
		Parent: Instance?,
		Size: UDim2,
		AnchorPoint: Vector2,
		Connection: RBXScriptConnection?,
		Position: UDim2,
	},
} =
	{}

---- PUBLIC VARIABLES ----
local GuiFollowMouse = {}

---- PRIVATE FUNCTIONS ----
local function positionGuiToMouse(guiObject: GuiObject): ()
	-- Also supports mobile.
	local playerMouse = UserInputService:GetMouseLocation()

	guiObject.Position =
		UDim2.fromOffset(playerMouse.X - (guiObject.AbsoluteSize.X / 2), playerMouse.Y - (guiObject.AbsoluteSize.Y / 2))
end

local function createConnection(guiObject: GuiObject): RBXScriptConnection
	local connection: RBXScriptConnection?
	if UserInputDevice.getInputDevice() == "Touch" then
		-- Update when the player drags their finger.
		connection = UserInputService.TouchMoved:Connect(function(): ()
			if not guiObject.Parent then
				return
			end

			positionGuiToMouse(guiObject)
		end)
	elseif UserInputDevice.getInputDevice() == "Keyboard/Mouse" then
		connection = UserInputService.InputChanged:Connect(function(input: InputObject): ()
			if not guiObject.Parent or input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end

			positionGuiToMouse(guiObject)
		end)
	else
		-- Console uses their virtual mouse, Thumbstick1 InputChanged only changes when its velocity changes,
		-- which looks choppy; as a workaround, update every frame.
		connection = RunService.Stepped:Connect(function(): ()
			positionGuiToMouse(guiObject)
		end)
	end

	guiObject.Destroying:Once(function(): ()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end)

	return connection :: any
end

function GuiFollowMouse.start(guiObject: GuiObject): ()
	if activeGuiObjects[guiObject] then
		return
	end -- Already active

	activeGuiObjects[guiObject] = {
		Position = guiObject.Position,
		Parent = guiObject.Parent,
		Size = guiObject.Size,
		AnchorPoint = guiObject.AnchorPoint,
		Connection = nil,
	}

	guiObject.Size = UDim2.fromOffset(guiObject.AbsoluteSize.X, guiObject.AbsoluteSize.Y)
	guiObject.AnchorPoint = Vector2.zero
	guiObject.Parent = GuiFollowMouseScreenGui

	positionGuiToMouse(guiObject)
	activeGuiObjects[guiObject].Connection = createConnection(guiObject)
end

function GuiFollowMouse.stop(guiObject: GuiObject): ()
	local data = activeGuiObjects[guiObject]
	if not data then
		return
	end -- Not active

	if data.Connection then
		data.Connection:Disconnect()
	end

	-- Restore original properties
	guiObject.Position = data.Position
	guiObject.Parent = data.Parent
	guiObject.Size = data.Size
	guiObject.AnchorPoint = data.AnchorPoint

	activeGuiObjects[guiObject] = nil
end

return GuiFollowMouse
