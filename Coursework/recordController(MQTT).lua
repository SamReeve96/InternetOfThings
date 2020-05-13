-- Init LED's
white = 0
green = 1
yellow = 2
red = 3
blue = 4

gpio.mode(white, gpio.OUTPUT)
gpio.write(white, gpio.LOW)

gpio.mode(green, gpio.OUTPUT)
gpio.write(green, gpio.LOW)

gpio.mode(yellow, gpio.OUTPUT)
gpio.write(yellow, gpio.HIGH)

gpio.mode(blue, gpio.OUTPUT)
gpio.write(blue, gpio.LOW)

gpio.mode(red, gpio.OUTPUT)
gpio.write(red, gpio.HIGH)

-- Init record player state Variables
plateSpinning = false
needleArmDown = true
speedRPM = 33
recordSize = 12
stateString = 'Record plate: ' .. tostring(plateSpinning) .. '\n' ..
                'Needle arm is down: ' .. tostring(needleArmDown) .. '\n' ..
                'Plate is spinning at: ' .. speedRPM .. '\n' ..
                'Current record size (inches) is : ' .. recordSize .. '\n'

-- Init Wireless
wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = "TP-Link_7BDB"
station_cfg.pwd = "71771489"
station_cfg.save = true
wifi.sta.config(station_cfg)
srv = net.createServer(net.TCP, 30)

-- Init remote console 
message = "-- Remote console online! --"

-- Start main function
mytimer = tmr.create()
mytimer:register(
    500,
    1,
    function()
        print(wifi.sta.getip())
        if wifi.sta.status() == wifi.STA_GOTIP then
           
            -- connect to the internet
            HOST="io.adafruit.com"
            PORT=1883
            ADAFRUIT_IO_USERNAME="839743"
            ADAFRUIT_IO_KEY="REMOVED FOR SECURITY"
            m = mqtt.Client("Client3", 300, ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)
           
            -- when connected, set LED indicator, setup controls and remote console
            m:on("connect", function(client)
                print("Client connected")
                print("MQTT client connected to"..HOST)

                gpio.mode(white, gpio.OUTPUT)
                gpio.write(white, gpio.HIGH)

                setupControls(client)
                SetupRemoteConsole(client)
            end)

            -- Set turntable to play a record
            function play()
                localMessage = 'Playing Music!'
                print(localMessage)
                plateSpinning = true
                needleArmOut = true
                gpio.mode(green, gpio.OUTPUT)
                gpio.write(green, gpio.HIGH)

                needleArmDown = true
                gpio.mode(yellow, gpio.OUTPUT)
                gpio.write(yellow, gpio.HIGH)
            end

            -- Set turntable to lift or drop needle
            function toggleNeedleArm()
                localMessage = 'Changing arm position!'

                if needleArmDown == false then
                    needleArmDown = true 
                    gpio.mode(yellow, gpio.OUTPUT)
                    gpio.write(yellow, gpio.HIGH)
                else
                    needleArmDown = false 
                    gpio.mode(yellow, gpio.OUTPUT)
                    gpio.write(yellow, gpio.LOW)
                end
            end

            -- Set turntable to stop playing a record
            function stop()
                localMessage = 'Stopped'
                print(localMessage)
                plateSpinning = false
                needleArmOut = false
                gpio.mode(green, gpio.OUTPUT)
                gpio.write(green, gpio.LOW)

                needleArmDown = true
                gpio.mode(yellow, gpio.OUTPUT)
                gpio.write(yellow, gpio.HIGH)
            end

            -- change turntable plate spin speed
            function changeSpeed(newSpeed)
                localMessage = 'Changing RPM!'
                print(localMessage)

                speedRPM = tonumber(newSpeed)

                if speedRPM >= 45 then
                    gpio.mode(blue, gpio.OUTPUT)
                    gpio.write(blue, gpio.HIGH)
                else
                    gpio.mode(blue, gpio.OUTPUT)
                    gpio.write(blue, gpio.LOW)
                end
            end

            -- change the needle drop position for the record
            function changeRecordSize(newSize)
                localMessage = 'Changing record size!'
                print(localMessage)

                recordSize = tonumber(newSize)

                if recordSize == 12 then
                    gpio.mode(red, gpio.OUTPUT)
                    gpio.write(red, gpio.HIGH)
                else
                    gpio.mode(red, gpio.OUTPUT)
                    gpio.write(red, gpio.LOW)
                end
            end

            -- Simulate a record being placed on the turntable bed
            function demoRecordPlacement(playtime)
                localMessage = "gonna play a record"
                print(localMessage)
                play()

                local playbackTimer = tmr.create()
                playbackTimer:register(playtime, tmr.ALARM_SINGLE, function (t)
                    print("record Ended, flip over or get another one");
                    stop()
                    t:unregister()
                end)
                playbackTimer:start()
            end

            -- update the values of the status update string
            function updateStateString()
                stateString = 'Record plate: ' .. tostring(plateSpinning) .. '\n' ..
                'Needle arm is down: ' .. tostring(needleArmDown) .. '\n' ..
                'Plate is spinning at: ' .. speedRPM .. '\n' ..
                'Current record size (inches) is : ' .. recordSize .. '\n'
                message = stateString;
            end            

            -- subscribe to MQTT control feeds
            function setupControls(client)
                -- Subscribe topic
                SUBSCRIBE_TOPIC_BASE = "839743/feeds/"
                client:subscribe(SUBSCRIBE_TOPIC_BASE .. "needle-control", 1, function(client)
                    print("needle-control Subscribe successfully")
                end)

                client:subscribe(SUBSCRIBE_TOPIC_BASE .. "record-size-control", 1, function(client)
                    print("record-size Subscribe successfully")
                end)

                client:subscribe(SUBSCRIBE_TOPIC_BASE .. "simulate-record-placement", 1, function(client)
                    print("simulate-record-placement Subscribe successfully")
                end)

                client:subscribe(SUBSCRIBE_TOPIC_BASE .. "speed-control", 1, function(client)
                    print("speed Subscribe successfully")
                end)
                
                client:subscribe(SUBSCRIBE_TOPIC_BASE .. "start-slash-stop-control", 1, function(client)
                    print("start stop control Subscribe successfully")
                end)
            end

            -- setup publish feed for remote console
            function SetupRemoteConsole(client)
                PUBLISH_TOPIC = "839743/feeds/console"
                mytimerPublish = tmr.create()
                mytimerPublish:register(500, 1,function()
                    if message ~= nil then
                        client:publish(PUBLISH_TOPIC, tostring(message), 1, 0, function(client)
                            print("Message Sent to Cloud: ", message)
                        end)
                        message = nil
                    end
                end)
                mytimerPublish:start()  
            end

            -- handle a message from the MQTT client
            m:on("message",function(client, topic, data)
                print(topic .. " " .. data)
                if topic ~= nil and data ~= nil then
                    if topic == "839743/feeds/needle-control" then
                        print("Needle changed")
                        print(data)
                        if data == "1" then
                            toggleNeedleArm()
                        else
                            print("button unclicked")
                        end
                    end

                    if topic == "839743/feeds/start-slash-stop-control" then
                        print("Starting or stopping")
                        if data == "Start" then
                            play()
                        end
                        if data == "Stop" then
                            stop()
                        end 
                    end

                    if topic == "839743/feeds/record-size-control" then
                        print("Changing record size")
                        changeRecordSize(data);
                    end

                    if topic == "839743/feeds/simulate-record-placement" then
                        print("Record placed!")
                         if data == "1" then
                            -- Test playback length value
                            demoRecordPlacement(10000)
                        else
                            print("button unclicked")
                        end
                    end

                    if topic == "839743/feeds/speed-control" then
                        print("Changing speed")
                        changeSpeed(data)
                    end

                    updateStateString()
                end
            end)

            -- If MQTT service is offline, turn of led indicator
            m:on("offline", function(client)
                print("Client offline")
                gpio.mode(white, gpio.OUTPUT)
                gpio.write(white, gpio.LOW)
            end)

            -- Handle connection error
            m:connect(HOST, PORT, false, false, function(conn) end, function(conn, reason)
                print("Fail! Failed reason is: "..reason)
            end)

            mytimer:stop()
        end
    end
)

mytimer:start()
