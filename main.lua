
local DropBoxManager = require( "DropBox" )
local widget = require( "widget" )

_W = display.contentWidth
_H = display.contentHeight


-- Layout Locations
local StatusMessageY = 420		-- position of status message

--------------------------------
-- Create Status Message area
--------------------------------
--
local function createStatusMessage( message, x, y )
	-- Show text, using default bold font of device (Helvetica on iPhone)
	local textObject = display.newText( message, 0, 0, native.systemFontBold, 24 )
	textObject:setTextColor( 255,255,255 )

	-- A trick to get text to be centered
	local group = display.newGroup()
	group.x = x
	group.y = y
	group:insert( textObject, true )

	-- Insert rounded rect behind textObject
	local r = 10
	local roundedRect = display.newRoundedRect( 0, 0, textObject.contentWidth + 2*r, textObject.contentHeight + 2*r, r )
	roundedRect:setFillColor( 55, 55, 55, 190 )
	group:insert( 1, roundedRect, true )

	group.textObject = textObject
	return group
end



local statusMessage = createStatusMessage( "   Not connected  ", 0.5*display.contentWidth, StatusMessageY )



local callback = {}

	-- Callbacks
	function callback.dropBoxCancel()
		print( "DropBox Cancel" )
		statusMessage.textObject.text = "DropBox Cancel"
	end

	function callback.dropBoxSuccess( msg )
		print( "DropBox Success: "..msg )
		statusMessage.textObject.text = "Msg: "..msg
	end

	function callback.dropBoxFailed()
		print( "Failed: Invalid Token" )
		statusMessage.textObject.text = "Failed: Invalid Token"

	end

local time

--------------------------------
-- Tweet the message
--------------------------------
--


local function dropit( event )
	time = os.date( "*t" )		-- Get time to append to our tweet
	local value = "Posted from Corona SDK at www.coronalabs.com at " ..time.hour .. ":"
			.. time.min .. "." .. time.sec

	DropBoxManager.drop(callback, value)
end

--------------------------------
-- Create "Tweet" Button
--------------------------------
--
-- Created without images
--
dropBoxButton = widget.newButton{
	id = "button1",
	label = "Request Access",
	left = _W*0.5,
	top = _H*0.5,
	width = 140, height = 50,
	fontSize = 40,
	labelColor = { default = {80, 80, 255}, over = {255} },
	strokeColor = {0},
	defaultColor = {255},
	overColor = {128},
	cornerRadius = 8,
	-- Interesting, you can call dropit with no ()'s
	--    and if you put in the ()'s it runs automatically without waiting for button press?
	onRelease = dropit
}
	
dropBoxButton.x = _W*0.5
dropBoxButton.y = _H*0.5
