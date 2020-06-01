-- Init Wireless
wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = ""
station_cfg.pwd = ""
station_cfg.save = true
wifi.sta.config(station_cfg)

function crawl()
    url='http://httpbin.org/ip'
    
    -- None of these will work due to not being JSON format.
    --url='http://www.amazon.co.uk'
    --url='http://wttr.in/'

    print(url)
    headers={['user-agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36'}
    --headers to avoid the website to recognise you as a robot
    http.request(url,'GET',headers,'',function(code, data)
        if (code<0) then
            print("HTTP request failed")
            print(code)
        else
            print(code, data)
        end
    end)
end

-- Start main function
mytimer = tmr.create()
mytimer:register(
    1500,
    1,
    function()
        print('connecting...')
        if wifi.sta.status() == wifi.STA_GOTIP then
            crawl()
            mytimer:stop()
        end
    end
)

mytimer:start()
