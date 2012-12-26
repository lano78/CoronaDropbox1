-- PROBLEM DESCRIPTION
--
-- This code works in the Corona Simulator on Windows, but not on my device, Droid X
-- Corona Version: 2012.881
-- Details:
--
-- By working in the simulator, I mean that I do get an event.response in rawPostRequest
--      and the response looks to be legitimate:
-- RESPONSE: oauth_token_secret=nqzgn7zm0122xtk&oauth_token=0v8ndd630842t0o
--
-- When I run the same code on my device, the Droid X, I get some kind of network error
--      because event.isError is true.  This occurred while my Droid X was connected to
--      a Wifi network and activity was tested in the browser. 

-- these are mine from my DropBox app
consumer_key = "w4kgympbnadebz2"            -- key string goes here
consumer_secret = "yh432tbbd5fx6mw"     -- secret string goes here
webURL = "http://google.com"

local dropbox_request = (oAuth.getRequestToken(consumer_key, webURL,
            "https://api.dropbox.com/1/oauth/request_token", consumer_secret))

-- this is my version of getRequestToken from the Twitter sample project
function getRequestToken(consumer_key, token_ready_url, request_token_url, consumer_secret)
 
        local post_data = 
        {
                oauth_consumer_key = consumer_key,
                oauth_timestamp    = get_timestamp(),
                oauth_version      = '1.0',
                --oauth_nonce        = get_nonce(),
                oauth_callback         = token_ready_url,
                oauth_signature_method = mySigMethod

        }
    
    local post_data = oAuthSign(request_token_url, "POST", post_data, consumer_secret)
    _G.response = rawPostRequest(request_token_url, post_data)
end


-- this is my version of rawPostRequest from the Twitter sample project
function rawPostRequest(url, rawdata)

        response = ""

        local function networkListener( event )
            if ( event.isError ) then
                print("Network error! in rawPostRequest in oAuth")
            else
                print("STATUS: "..event.status)
                print ( "RESPONSE: " .. event.response )
                response = event.response
                _G.response = event.response
            end
        end

        headers = {}

        headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers["Content-Length"] = string.len(rawdata)

        body = rawdata

        local params = {}
        params.headers = headers
        params.body = body

        network.request( url, "POST", networkListener,  params) 

        return response
end
