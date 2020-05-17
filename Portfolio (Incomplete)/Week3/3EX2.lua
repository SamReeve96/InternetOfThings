dhtPin = 1

mytimer = tmr.create()
mytimer:alarm(
    5000, --Not sure on an ideal interval...
    tmr.ALARM_AUTO,
    function()
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
)
