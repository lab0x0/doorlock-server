pin = 0
pin1 = 1

gpio.mode(pin,gpio.OUTPUT)
gpio.mode(pin1,gpio.OUTPUT)

ready = 0
wifi.setmode(wifi.STATION)

wifi.sta.config("ssid_name","ssid_password") -- wifi settings

function wifi_connect()
   ip = wifi.sta.getip()
     if ip ~= nill then
          print("WIFI")
          tmr.stop(1)
          ready = 1
     else
          ready = 0
     end
end

function mqtt_do()
if ready == 1 then
  m = mqtt.Client("door_lock", 120, "", "") -- mqtt client name
  m:connect( "0.0.0.0", 1883, 0, -- mqtt server ip or adress
  function(conn)
    print("MQTT")
    tmr.stop(0)
    connected = 1;
    tmr.delay(1000)
    mqtt_sub()
  end)
end
end

function mqtt_sub()
    m:subscribe("topic_name",0, function(conn) print("subscribed") end) -- mqtt topic name
    tmr.delay(2000)
    main_prog()
end



tmr.alarm(0, 1000, 1, function() 
     mqtt_do()
     tmr.delay(1000)
     end)
     
tmr.alarm(1, 1111, 1, function()
     wifi_connect() 
     end)

tmr.alarm(2, 30000000, 1, function() -- restart every 5 minites (need to rewrite)
     node.restart();
     end)



function main_prog()


m:on("message", function(conn, topic, msg)     
   if (msg=="open") then
      gpio.write(pin,gpio.LOW)
      gpio.write(pin1,gpio.LOW) 

        
      print("activating door")   
      tmr.delay(5000000) -- wait 5 seconds
      gpio.write(pin,gpio.HIGH) 
      gpio.write(pin1,gpio.HIGH)  

   else  
      print("invalid comand")   
   end   
end)  


end
