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

-- init functions that are executed based on request string 
function handleRequest(request)
    if request == 'play' then
        play()
    elseif request == 'pause' then
        pause()
    elseif request == 'stop' then
        stop()
    elseif request == 'changeSpeed' then
        changeSpeed()
    elseif request == 'changeRecordSize' then
        changeRecordSize()
    elseif request == 'placedNewRecord' then
        demoRecordPlacement()
    end
    updateStateString()
end

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
function demoRecordPlacement()
    localMessage = "gonna play a record"
    print(localMessage)
    play()
    --demo testing time
    playtime = 10000

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

-- Init Wireless
wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = "TP-Link_7BDB"
station_cfg.pwd = "71771489"
station_cfg.save = true
wifi.sta.config(station_cfg)
srv = net.createServer(net.TCP, 30)

-- Start main function
mytimer = tmr.create()
mytimer:register(
    500,
    1,
    function()
        print(wifi.sta.getip())
        if wifi.sta.status() == wifi.STA_GOTIP then

            srv:listen(
                2020,
                function(conn)
                    -- Got a client! Light up white led
                    gpio.mode(white, gpio.OUTPUT)
                    gpio.write(white, gpio.HIGH)
                    conn:send('\n' .. "Hello! lets play some music, currently: \n" .. stateString)
                    conn:on(
                        "receive",
                        function(conn, s)
                            print(s)
                            conn:send(s)
                        end
                    )
                    conn:on(
                        "connection",
                        function(conn, s)
                            conn:send("hello! sent from Server\n")
                        end
                    )
                    conn:on(
                        "disconnection",
                        function(conn, s)
                            print("disconnected\n")
                            -- lost client! dim white led
                            gpio.mode(white, gpio.OUTPUT)
                            gpio.write(white, gpio.LOW)
                        end
                    )
                    conn:on(
                        "sent",
                        function(conn, s)
                            print("Message has been sent out from the Server\n")
                        end
                    )
                    conn:on(
                        "receive",
                        function(conn, request)
                            print("Request received!\n" .. request .. "\n")
                            handleRequest(request)
                            conn:send("Current State" .. stateString)
                        end
                    )
                end
            )
            mytimer:stop()
        end
    end
)

mytimer:start()
