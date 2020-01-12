#!/bin/bash
loginurl="https://cas.sustech.edu.cn/cas/login"
authip="219.134.142.194"
username="YOUR_USER_NAME_HERE"
password="YOUR_PASSWORD_HERE"

header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36"

last_state="init"
current_state="init"

last_timestamp=$(date "+%s")

while true; do
  ret_code=$(curl -I -s --connect-timeout 5 http://www.baidu.com -w %{http_code} | tail -n1)
  current_timestamp=$(date "+%s")

  if [ "$ret_code" -ne 200 ]; then
    current_state="TRY_CONNECT"

    rm -f /tmp/cascookie

    routerip=$(ifconfig | grep -A 1 "eth0.2" | grep -o "\(inet addr:\).*  Bcast" | grep -o "[0-9\.]*")
    eneturl="http://enet.10000.gd.cn:10001/sz/sz112/index.jsp?wlanuserip=$routerip&wlanacip=$authip"
    execution=$(curl --silent --cookie-jar /tmp/cascookies -H "$header" -k -L "$eneturl" | grep -o 'execution.*/><input type' | grep -o '[^"]\{50,\}')

    curl --silent --output /dev/null --cookie /tmp/cascookies --cookie-jar /tmp/cascookies -H "Content-Type: application/x-www-form-urlencoded" -H "$header" -k -L -X POST "$loginurl" --data "username=$username&password=$password&execution=$execution&_eventId=submit&geolocation="
  else
    current_state="CONNECTED"
  fi

  if [ "$last_state" != "$current_state" ] || ((current_timestamp - last_timestamp > 60 * 60 * 12)); then
    time=$(date "+[%Y.%m.%d %H:%M:%S]")
    if [ $current_state == "CONNECTED" ]; then
      echo "$time Connected to Internet, recheck a second later"
    fi
    if [ $current_state == "TRY_CONNECT" ]; then
      echo "$time Attempting to log in the enet system"
    fi
    last_state=$current_state
    last_timestamp=$current_timestamp
  fi

  sleep 1s
done
