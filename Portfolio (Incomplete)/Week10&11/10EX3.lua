-- Init Wireless
wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = ""
station_cfg.pwd = ""
station_cfg.save = true
wifi.sta.config(station_cfg)

function post(postData)
    http.post(
        "http://httpbin.org/post",
        "Content-Type: application/json\r\n",
        '{"File":' .. postData .. '}',
        function(code, data)
            if (code < 0) then
                print("HTTP request failed")
            else
                print(code)
                print(data)
            end
        end
    )
end

function getData()
    url='http://httpbin.org/ip'
    --headers to avoid the website to recognise you as a robot
    headers={['user-agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36'}
    http.request(url,'GET',headers,'',function(code, data)
        if (code<0) then
            print("HTTP request failed")
            print(code)
        else
            print(code, data)
            --Write data to a new file
            newFile = file.open("requestData.txt", "w")
            newFile:writeline(data)
            newFile:close()

            -- post file contents to test site 
            newFileContents = file.getcontents('requestData.txt')
            post(newFileContents)
        end
    end)
end

-- Start main function
mytimer = tmr.create()
mytimer:register(
    1500,
    1,
    function()
        print("connecting...")
        if wifi.sta.status() == wifi.STA_GOTIP then
            getData()
            mytimer:stop()
        end
    end
)

mytimer:start()

