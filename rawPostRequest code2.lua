function rawPostRequest(url, rawdata)

        response = ""

        local function networkListener( event )
            if ( event.isError ) then
                --print("error is: "..event.isError)
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
