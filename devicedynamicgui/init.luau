--!strict
--[[
    Resizes and repositions GuiObjects based on the player's device.
    Mobile should be bigger, and should move away to not cover other GuiObjects.
]]
---- SERVICES ----
local CollectionService = game:GetService("CollectionService")
local ConnectivityService = game:GetService("ConnectivityService")

---- MODULES ----
local GetAttributeSafe = require(script.Parent.GetAttributeSafe)
local UserInputDevice = require(script.Parent.UserInputDevice)

---- PRIVATE CONSTANTS ----
local TAG_DYNAMIC_GUI = "DeviceDynamicGui"
local ATTR_MOBILE_SIZE = "MobileSize"
local ATTR_NORMAL_SIZE = "NormalSize"
local ATTR_MOBILE_POSITION = "MobilePosition"
local ATTR_NORMAL_POSITION = "NormalPosition"

---- PRIVATE FUNCTIONS ----
local function processGuiObject(guiObject: Instance): ()
	if not guiObject:IsA("GuiObject") then
		return
	end

	-- Get the sizes to update to.
	local mobileSize = GetAttributeSafe(guiObject, ATTR_MOBILE_SIZE, "UDim2", guiObject.Size)
	local normalSize = GetAttributeSafe(guiObject, ATTR_NORMAL_SIZE, "UDim2", guiObject.Size)
	local mobilePosition = GetAttributeSafe(guiObject, ATTR_MOBILE_POSITION, "UDim2", guiObject.Position)
	local normalPosition = GetAttributeSafe(guiObject, ATTR_NORMAL_POSITION, "UDim2", guiObject.Position)

	local function update(): ()
		if UserInputDevice.getInputDevice() == "Touch" then
			guiObject.Size = mobileSize
			guiObject.Position = mobilePosition
		else
			guiObject.Size = normalSize
			guiObject.Position = normalPosition
		end
	end

	-- Update the GUI again when the player's input device has changed.
	local deviceConnection = UserInputDevice.DeviceChanged:Connect(update)

	-- Object has been destroyed, no need to update anymore.
	-- To prevent memory leak.
	guiObject.Destroying:Once(function(): ()
		deviceConnection:Disconnect()
		deviceConnection = nil :: any
	end)

	-- Initialize.
	update()
end

---- INITIALIZE ----
-- Process existing objects.
for _, guiObject in CollectionService:GetTagged(TAG_DYNAMIC_GUI) do
	processGuiObject(guiObject)
end

-- Process new objects.
CollectionService:GetInstanceAddedSignal(TAG_DYNAMIC_GUI):Connect(processGuiObject)

return
