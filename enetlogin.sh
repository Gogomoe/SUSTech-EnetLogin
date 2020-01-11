#!/bin/bash
loginurl="https://cas.sustech.edu.cn/cas/login"
authip="219.134.142.194"
username="YOUR_USER_NAME_HERE"
password="YOUR_PASSWORD_HERE"

header="User-Agent: Mozilla/5.0"

is_connected=false
timestamp=$(date "+%s")

while true
do
  ret_code=$(curl -I -s --connect-timeout 5 http://www.baidu.com -w %{http_code} | tail -n1)

  time=$(date "+[%Y.%m.%d %H:%M:%S]")
  timestamp_now=$(date "+%s")

  if [ "x$ret_code" != "x200" ] ; then
    echo "$time Attempting to log in the enet system"

    rm -f /tmp/cascookie

    routerip=$(ifconfig | grep -A 1 "eth0.2" | grep -o "\(inet addr:\).*  Bcast" | grep -o "[0-9\.]*")
    eneturl="http://enet.10000.gd.cn:10001/sz/sz112/index.jsp?wlanuserip=$routerip&wlanacip=$authip"
    execution=$(curl --silent --cookie-jar /tmp/cascookies -k -L "$eneturl" -H "$header" | grep -o 'execution.*/><input type' | grep -o '[^"]\{50,\}')
    echo $execution;
    curl --silent --output /dev/null --cookie /tmp/cascookies --cookie-jar /tmp/cascookies -H "Content-Type: application/x-www-form-urlencoded" -H "$header" -k -L -X POST "$loginurl" --data "username=$username&password=$password&execution=$execution&_eventId=submit&geolocation="
  else
    if [ "$is_connected" == false ] || [ $((timestamp_now - timestamp > 60*60*12)) ]; then
      timestamp=$timestamp_now
      echo "$time Connected to Internet, recheck a second later"
    fi
    is_connected=true
  fi
  sleep 1s
done
