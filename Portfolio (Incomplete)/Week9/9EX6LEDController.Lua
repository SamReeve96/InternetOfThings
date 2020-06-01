-- Init Wireless
wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = ""
station_cfg.pwd = ""
station_cfg.save = true
wifi.sta.config(station_cfg)
srv = net.createServer(net.TCP, 30)

-- Setup LED
LED = 1
adcV = 1023
pwm.setup(LED, 1000, adcV)
pwm.start(LED)

function updateADCV(value)
    adcV = value
    pwm.setduty(LED, adcV)
end

-- Start main function
mytimer = tmr.create()
mytimer:register(
    500,
    1,
    function()
        print(wifi.sta.getip())
        if wifi.sta.status() == wifi.STA_GOTIP then
            -- connect to the internet
            HOST = "io.adafruit.com"
            PORT = 1883
            ADAFRUIT_IO_USERNAME = "839743"
            ADAFRUIT_IO_KEY = ""
            m = mqtt.Client("Client", 300, ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

            -- when connected
            m:on(
                "connect",
                function(client)
                    print("Client connected")
                    print("MQTT client connected to" .. HOST)

                    -- Misc note: reusing a feed from Coursework due to ADA Fruit feed limit
                    SUBSCRIBE_TOPIC = "839743/feeds/speed-control"
                    client:subscribe(
                        SUBSCRIBE_TOPIC,
                        1,
                        function(client)
                            print("Subscribe successfully")
                        end
                    )
                end
            )

            -- handle a message from the MQTT client
            m:on(
                "message",
                function(client, topic, data)
                    print(topic .. " " .. data)
                    if topic ~= nil and data ~= nil then
                        -- Misc note: reusing a feed from Coursework due to ADA Fruit feed limit
                        if topic == "839743/feeds/speed-control" then
                            updateADCV(data)
                        end
                    end
                end
            )

            -- If MQTT service is offline
            m:on(
                "offline",
                function(client)
                    print("Client offline")
                end
            )

            -- Handle connection error
            m:connect(
                HOST,
                PORT,
                false,
                false,
                function(conn)
                end,
                function(conn, reason)
                    print("Fail! Failed reason is: " .. reason)
                end
            )

            mytimer:stop()
        end
    end
)

mytimer:start()
