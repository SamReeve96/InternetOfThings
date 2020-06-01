wifi.sta.autoconnect(1)
wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = ""
station_cfg.pwd = ""
station_cfg.save = true
wifi.sta.config(station_cfg)

srv = net.createServer(net.TCP, 30)
--TCP, 30s for an inactive client to be disconnected
--try srv = net.createServer(net.UDP,10)
srv:listen(
    2020,
    function(conn)
        conn:send("Send to all clients who connect to Port 80 \n")
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
                conn:send("Connected\n")
            end
        )
        conn:on(
            "disconnection",
            function(conn, s)
                print("Disconnected\n")
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
            function(conn, s)
                print("Request received!\n" .. s .. "\n")
            end
        )
    end
)
--srv:close()
