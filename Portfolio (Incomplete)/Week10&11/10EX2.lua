-- Init Wireless
wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = ""
station_cfg.pwd = ""
station_cfg.save = true
wifi.sta.config(station_cfg)

function post()
    http.post(
        "http://httpbin.org/post",
        "Content-Type: application/json\r\n",
        '{"IoT":"2020","This is":"Json Format","Please check":' .. '"The formating of the structure"}',
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

function put()
    http.put(
        "http://httpbin.org/put",
        "Content-Type: text/plain\r\n",
        "IoT 2020 plain text, please check how the data is formatted",
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

function delete()
    http.delete(
        "http://httpbin.org/delete",
        "",
        "",
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

-- Start main function
mytimer = tmr.create()
mytimer:register(
    1500,
    1,
    function()
        print("connecting...")
        if wifi.sta.status() == wifi.STA_GOTIP then
            --uncomment functions to test them
            --print('posting')
            --post()
            print('putting')
            put()
            --print('Deleting')
            --delete()
            mytimer:stop()
        end
    end
)

mytimer:start()
