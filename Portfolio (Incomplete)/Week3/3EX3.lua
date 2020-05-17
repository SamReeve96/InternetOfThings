buttonPin = 0
gpio.mode(buttonPin, gpio.INPUT)
gpio.write(buttonPin, gpio.LOW)
buttonDown = 0

dhtPin = 1

mytimer = tmr.create()
mytimer:register(
    1000,
    1,
    function()
        while gpio.read(buttonPin) == 1 do
            if buttonDown == 1 then
            
            else
                buttonDown = 1
                print("Button detected")
                status, temp, humi, temp_dec, humi_dec = dht.read11(dhtPin)
                if status == dht.OK then
                    --dht.OK, dht.ERROR_CHECKSUM, dht.ERROR_TIMEOUT
                    print("DHT Temperature:" .. temp .. ";" .. "Humidity:" .. humi)
                elseif status == dht.ERROR_CHECKSUM then
                    print("DHT Checksum error.")
                elseif status == dht.ERROR_TIMEOUT then
                    print("DHT timed out.")
                end
            end
        end

        if gpio.read(buttonPin) == 0 then
            buttonDown = 0
        end
    end
)
mytimer:start()
