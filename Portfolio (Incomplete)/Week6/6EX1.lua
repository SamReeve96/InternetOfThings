---- STATION MODE
wifi.sta.autoconnect(1)
--autoconnect
wifi.setmode(wifi.STATION)

station_cfg = {}

--REMOVE VALUES WHEN COMMITING TO REPOSITORY
station_cfg.ssid = ""
station_cfg.pwd = ""

station_cfg.save = true
wifi.sta.config(station_cfg)

cl = net.createConnection(net.TCP, 0)
--create a TCP based not encryped client
cl:on(
    "connection",
    function(conn, s)
        conn:send("Now connected, hello samuel\n")
    end
)
cl:on(
    "disconnection",
    function(conn, s)
        print("Disconnected\n")
    end
)
cl:on(
    "sent",
    function(conn, s)
        print("Message has been sent out\n")
    end
)
cl:on(
    "receive",
    function(conn, s)
        print("Got this from the server\n" .. s .. "\n")
    end
)

--the local IP of your test server
cl:connect(1990, "192.168.8.100")
