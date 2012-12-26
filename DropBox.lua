-- Project: Twitter sample app
--
-- File name: Twitter.lua
--
-- Author: Corona Labs
--
-- Abstract: Demonstrates how to connect to Twitter using Oauth Authenication.
--
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
-----------------------------------------------------------------------------------------

module(..., package.seeall)

local oAuth = require "oAuth"
local widget2 = require( "widget" )
_W = display.contentWidth
_H = display.contentHeight

-- Fill in the following fields from your Twitter app account
consumer_key = ""			-- key string goes here
consumer_secret = ""		-- secret string goes here

-- The web URL address below can be anything
-- Twitter sends the webaddress with the token back to your app and the code strips out the token to use to authorise it
--
webURL = "http://google.com"

-- Note: Once logged on, the access_token and access_token_secret should be saved so they can
--	     be used for the next session without the user having to log in again.
-- The following is returned after a successful authenications and log-in by the user
--
local access_token
local access_token_secret
local user_id
local screen_name

-- Local variables used in the tweet
local postMessage
local delegate

-- Display a message if there is not app keys set
--
if not consumer_key or not consumer_secret then
	-- Handle the response from showAlert dialog boxbox
	--
	print("can't find key or secret")
	local function onComplete( event )
		if event.index == 1 then
			system.openURL( "https://www.dropbox.com/developers/start" )
		end
	end

	native.showAlert( "Error", "To develop for DropBox, you need to get an API key and application secret. This is available from Twitter's website.",
		{ "Learn More", "Cancel" }, onComplete )
end

-----------------------------------------------------------------------------------------
-- Twitter Authorization Listener
-----------------------------------------------------------------------------------------
--
local function listener(event)
	print("listener: ", event.url)
	local remain_open = true
	local url = event.url

	if url:find("oauth_token") and url:find(webURL) then
		url = url:sub(url:find("?") + 1, url:len())

		local authorize_response = responseToTable(url, {"=", "&"})
		remain_open = false

		local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token,
			authorize_response.oauth_verifier, twitter_request_token_secret,
			consumer_key, consumer_secret, "https://api.dropbox.com/1/oauth/access_token"), {"=", "&"})
		
		access_token = access_response.oauth_token
		access_token_secret = access_response.oauth_token_secret
		user_id = access_response.user_id
		screen_name = access_response.screen_name
		
		print( "Dropping" )
		
			-- API CALL:
		------------------------------
		--change the message posted
		local params = {}
		params[1] =
		{
			key = 'display_name',
			value = postMessage
		}
		
		request_response = oAuth.makeRequest("https://api.dropbox.com/1/account/info",
			params, consumer_key, access_token, consumer_secret, access_token_secret, "GET")
			
		--`print("req resp ",request_response)
		
		delegate.dropBoxSuccess()

	elseif url:find(webURL) then
		-- Logon was canceled
		remain_open = false
		delegate.dropBoxCancel()
		
	end

	return remain_open
end

-----------------------------------------------------------------------------------------
-- RESPONSE TO TABLE
--
-- Strips the token from the web address returned
-----------------------------------------------------------------------------------------
--
function responseToTable(str, delimeters)
	local obj = {}

	while str:find(delimeters[1]) ~= nil do
		if #delimeters > 1 then
			local key_index = 1
			local val_index = str:find(delimeters[1])
			local key = str:sub(key_index, val_index - 1)
	
			str = str:sub((val_index + delimeters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimeters[2]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimeters[2])
				value = str:sub(1, (end_index - 1))
				str = str:sub((end_index + delimeters[2]:len()), str:len())
			end
			obj[key] = value
			--print(key .. ":" .. value)		-- **debug
		else
	
			local val_index = str:find(delimeters[1])
			str = str:sub((val_index + delimeters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimeters[1]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimeters[1])
				value = str:sub(1, (end_index - 1))
				str = str:sub(end_index, str:len())
			end
			
			obj[#obj + 1] = value
			--print(value)					-- **debug
		end
	end
	
	return obj
end

-----------------------------------------------------------------------------------------
-- Tweet
--
-- Sends the tweet. Authorizes if no access token
-----------------------------------------------------------------------------------------
--
function drop(del, msg)
	postMessage = msg
	delegate = del
	
	-- Check to see if we are authorized to tweet
	if not access_token then
		print( "Authorizing account" )
		
		if not consumer_key or not consumer_secret then
			print("consumer_key: "..consumer_key)
			print("consumer_secret: "..consumer_secret)
			-- Exit if no API keys set (avoids crashing app)
			delegate.dropBoxFailed()
			return
		end
		
		-- Need to authorize first
		--
		-- Get temporary token
		--//TODO: this is where the problem is occurring
		print("about to do getRequestToken")
		local dropbox_request = (oAuth.getRequestToken(consumer_key, webURL,
			"https://api.dropbox.com/1/oauth/request_token", consumer_secret))
		
		dropBoxButton2 = widget2.newButton{
		        id = "button2",
		        label = "Authorize",
		        left = _W*0.5,
		        top = _H*0.7,
		        width = 140, height = 50,
		        fontSize = 40,
		        labelColor = { default = {80, 80, 255}, over = {255} },
		        strokeColor = {0},
		        defaultColor = {255},
		        overColor = {128},
		        cornerRadius = 8,
		        -- Interesting, you can call dropit with no ()'s
		        --    and if you put in the ()'s it runs automatically without waiting for button press?
		        onRelease = function()
		            local token = _G.response:match('oauth_token=([^&]+)')
		            --print("token: "..token)
        		    local token_secret = _G.response:match('oauth_token_secret=([^&]+)')
            		--print("token_secret: "..token_secret)    

					print("completed getRequestToken")
					print("_G.response: ".._G.response.."")
					print("token: "..token.."")
					--print(consumer_secret)
					local dropbox_request_token = token
					print("dropbox_request_token: "..dropbox_request_token.."")
					local dropbox_request_token_secret = token_secret
					print("dropbox_request_token_secret: "..dropbox_request_token_secret.."")

					if not dropbox_request_token then
						-- No valid token received. Abort
						print("dropbox_request_token not found")
						delegate.dropBoxFailed()
						return
					end

					print("dropbox_request_token found")
					
					-- Request the authorization
					native.showWebPopup(0, 0, 320, 480, "https://www.dropbox.com/1/oauth/authorize?oauth_token="
						.. dropbox_request_token, {urlRequest = listener})

		        end -- end of onRelease function
		    } -- end of dropBoxButton2
        
	    dropBoxButton2.x = _W*0.5
    	dropBoxButton2.y = _H*0.7


		-- print("completed getRequestToken")
		-- --print(consumer_secret)
		-- local dropbox_request_token = dropbox_request.token
		-- print("dropbox_request_token: "..dropbox_request_token)
		-- local dropbox_request_token_secret = dropbox_request.token_secret
		-- print("dropbox_request_token_secret: "..dropbox_request_token_secret)

		-- if not dropbox_request_token then
		-- 	-- No valid token received. Abort
		-- 	print("dropbox_request_token not found")
		-- 	delegate.dropBoxFailed()
		-- 	return
		-- end

		-- print("dropbox_request_token found")
		
		-- -- Request the authorization
		-- native.showWebPopup(0, 0, 320, 480, "https://www.dropbox.com/1/oauth/authorize?oauth_token="
		-- 	.. dropbox_request_token, {urlRequest = listener})

	else
		print( "Dropping" )
		
		------------------------------
		-- API CALL:
		------------------------------
		--change the message posted
		local params = {}
		params[1] =
		{
			key = 'display_name',
			value = postMessage
		}
		
		--request_response = oAuth.makeRequest("http://requestb.in/rllkvvrl", 

		request_response = oAuth.makeRequest("https://api.dropbox.com/1/account/info",
			params, consumer_key, access_token, consumer_secret, access_token_secret, "GET")
			
		--print("Tweet response: ",request_response)
		
		delegate.dropBoxSuccess(request_response)
	end
end