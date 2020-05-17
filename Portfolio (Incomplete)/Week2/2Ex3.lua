dc = 1023
pinDim = 3
pwm.setup(pinDim, 1000, dc)
pwm.start(pinDim)

direction = 'lightToDark'

mytimer = tmr.create()
mytimer:alarm(
    200,
    tmr.ALARM_AUTO,
    function()
        if direction == 'lightToDark' then
            dc = dc - 10
            print(dc)
            pwm.setduty(pinDim, dc)
            if (dc < 10) then
                direction = 'darkToLight'
            end
        elseif direction == 'darkToLight' then
            dc = dc + 10
            print(dc)
            pwm.setduty(pinDim, dc)
            if (dc == 1023) then
                direction = 'lightToDark'
            end
        end
    end
)