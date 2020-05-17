pinLED1 = 4
pinLED2 = 0

mytimer = tmr.create()
mytimer:register(
    2000,
    1,
    function()
        pinLED1State = gpio.read(pinLED1)
        pinLED2State = gpio.read(pinLED2)

        if pinLED1State == 0 then
        gpio.mode(pinLED1, gpio.OUTPUT)
        gpio.write(pinLED1, gpio.HIGH)
        gpio.mode(pinLED2, gpio.OUTPUT)
        gpio.write(pinLED2, gpio.LOW)
        else
        gpio.mode(pinLED1, gpio.OUTPUT)
        gpio.write(pinLED1, gpio.LOW)
        gpio.mode(pinLED2, gpio.OUTPUT)
        gpio.write(pinLED2, gpio.HIGH)
        end
    end
)
mytimer:start()
