--!strict
--[[
    Resizes and repositions GuiObjects based on the player's device.
    Mobile should be bigger, and should move away to not cover other GuiObjects.
]]
---- SERVICES ----
local CollectionService = game:GetService("CollectionService")

---- MODULES ----
local GetAttributeSafe = require(script.Parent.GetAttributeSafe)
local UserInputDevice = require(script.Parent.UserInputDevice)

---- PRIVATE CONSTANTS ----
local TAG_DYNAMIC_GUI = "DeviceDynamicGui"
local ATTR_MOBILE_SIZE = "MobileSize"
local ATTR_NORMAL_SIZE = "NormalSize"
local ATTR_MOBILE_POSITION = "MobilePosition"
local ATTR_NORMAL_POSITION = "NormalPosition"

---- FUNCTIONS ----
local function processGuiObject(guiObject: Instance): ()
	if not guiObject:IsA("GuiObject") then
		return
	end

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

	UserInputDevice.DeviceChanged:Connect(update)
	update()
end

-- Process existing objects.
for _, guiObject in CollectionService:GetTagged(TAG_DYNAMIC_GUI) do
	processGuiObject(guiObject)
end

-- Process new objects.
CollectionService:GetInstanceAddedSignal(TAG_DYNAMIC_GUI):Connect(processGuiObject)

return table.freeze({})
