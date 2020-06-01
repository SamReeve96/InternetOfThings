wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = ""
station_cfg.pwd = ""
station_cfg.save = false
wifi.sta.config(station_cfg)

tmsrv = "uk.pool.ntp.org"
--an optional NTP server
function stampTime()
    --get the stamp of the time from synchronized clock

    sec, microsec, rate = rtctime.get()
    tm = rtctime.epoch2cal(sec, microsec, rate)
    print(
        string.format(
            "%04d/%02d/%02d %02d:%02d:%02d",
            tm["year"],
            tm["mon"],
            tm["day"],
            tm["hour"],
            tm["min"],
            tm["sec"]
        )
    )
end

cron.schedule(
    "0 7 * * *",
    function(e)
        print("\n Alarm Clock \n It is 07:00!!! \n Here's the weather! \n")
        getWeather()
    end
)

keyAPI = ""
lat = ""
long = ""

function getWeather()
    --Using the longitude and latitude of Portsmouth to retrieve weather data
    urlAPI = "http://api.openweathermap.org/data/2.5/weather?lat=" .. lat .. "&lon=" .. long .. "&APPID=" .. keyAPI
    http.get(
        urlAPI,
        nil,
        function(code, data)
            if (code < 0) then
                --200 is success code
                print("http request failed")
            else
                print(code)
                obj:write(data)
                WeatherObjectToString(weatherObject)
            end
        end
    )
end

mytimer = tmr.create()
mytimer:register(
    500,
    1,
    function()
        print(wifi.sta.getip())
        if wifi.sta.status() == wifi.STA_GOTIP then
            sntp.sync(
                tmsrv,
                function()
                    print("Sync succeeded")
                    mytimer:stop()
                    stampTime()
                end,
                function()
                    print("Synchronization failed!")
                end
            )
            mytimer:stop()
        end
    end
)

weatherObject = {}
metaTable = {}
t = {metatable = metaTable}
metaTable.__newindex = function(table, key, value)
    if (key == "description") or (key == "temp") or (key == "humidity") or (key == "speed") then
        rawset(weatherObject, key, value)
    end
end

-- Convert Json to object
obj = sjson.decoder(t)

-- Print Lua object to String
function WeatherObjectToString(t)
    print("\nWeather Today: " .. t["description"])
    print("\nTemperature: " .. t["temp"] - 273.15)
    print("\nHumidity: " .. t["humidity"])
    print("\nWind Speed: " .. t["speed"])
end

mytimer:start()
