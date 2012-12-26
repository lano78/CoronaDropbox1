function rawPostRequest(url, rawdata)

    local response = ""

    local function networkListener( event )
        if ( event.isError ) then
            print("Network error!")
        else
            print ( "RESPONSE: " .. event.response )
            response = event.response
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
