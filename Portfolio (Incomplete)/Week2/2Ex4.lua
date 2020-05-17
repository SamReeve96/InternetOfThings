-- For example, the Green light is ON for 4 seconds, then OFF and Yellow light is ON
-- for 0.5 seconds, then Red light is ON for 2 seconds, then OFF and Yellow light is
-- ON for 0.5 seconds. (Red, Yellow, Green, Yellow, Red, ...)

Green = 1
pwm.setup(Green, 1000, 0)
pwm.start(Green)

Yellow = 2
pwm.setup(Yellow, 1000, 0)
pwm.start(Yellow)

Red = 3
pwm.setup(Red, 1000, 0)
pwm.start(Red)

goStateLength = 4.0
stopStateLength = 2.0
waitStateLength = 0.5

state = 'go'
length = goStateLength
-- endingGo
-- stop
-- endingStop

function trafficLight(dc_g, dc_y, dc_r)
    pwm.setduty(Green, dc_g)
    pwm.setduty(Yellow, dc_y)
    pwm.setduty(Red, dc_r)
end

mytimer = tmr.create()
mytimer:alarm(
    500, --Evaluate every half a second
    tmr.ALARM_AUTO,
    function()
        length = length - 0.5
        if state == 'go' then
            trafficLight(1023, 0, 0)
            if length == 0 then
                state = 'endingGo'
                length = waitStateLength
            end
        elseif state == "stop" then
            trafficLight(0, 0, 1023)
            if length == 0 then
                state = 'endingStop'
                length = waitStateLength
            end
        else
            trafficLight(0, 1023, 0)
            if length == 0 then
                if state == 'endingGo' then
                    state = 'stop'
                    length = stopStateLength
                elseif state == 'endingStop' then
                    state = 'go'
                    length = goStateLength
                end
            end
        end
    end
)
