-- Init Wireless
wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = ""
station_cfg.pwd = ""
station_cfg.save = true
wifi.sta.config(station_cfg)
srv = net.createServer(net.TCP, 30)

--Get adcv pin, value etc. 
pinADC = 0
adcV = 0

-- Setup LED
LED = 1
pwm.setup(LED, 1000, adcV)
pwm.start(LED)

function pubADC(client)
    PUBLISH_TOPIC = "839743/feeds/console"
    mytimerPublish = tmr.create()
    mytimerPublish:register(
        2000,
        1,
        function()
            client:publish(
                PUBLISH_TOPIC,
                tostring(adcV),
                1,
                0,
                function(client)
                    --get current ADC value (subtract one to keep under 1024 (adc ranges from 0-1023))
                    adcV = adc.read(pinADC)

                    print(adcV)
                    if adcV == 1024 then
                        adcV = adcV - 1
                    end

                    pwm.setduty(LED, adcV);
                    print("ADC reading sent: ", adcV)
                end
            )
        end
    )
    mytimerPublish:start()
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
            m = mqtt.Client("Client1", 300, ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

            -- when connected
            m:on(
                "connect",
                function(client)
                    print("Client connected")
                    print("MQTT client connected to" .. HOST)
                    pubADC(client)
                end
            )

            -- handle a message from the MQTT client
            m:on(
                "message",
                function(client, topic, data)
                    print(topic .. " " .. data)
                    if topic ~= nil and data ~= nil then
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
