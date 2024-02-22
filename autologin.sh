#! /bin/bash

# Router detail
interface="wlx00e0257fe944"
ipc=""
mac=""
key=""

# Account detail
username="gimanaya"
password="gimanaya"
type="wmslite"
sid="1773207908"
gw_id="WAG-D2-CKA"
wlan="GPON05-D2-TGA-3%20pon%2016/15/2/1:4090:ABDILLAH"
sessionid="WAG-D2-12202364400000a64117008807"

check() {
    x=`ping -c1 8.8.8.8 2>&1 | grep 100%`
    if [ ! "$x" = "" ]; then
        refresh
        connect
    else
        echo "Koneksi sudah tersambung"
    fi
}

refresh() {
    echo "Merefresh interface..."
    ip link set $interface down
    ip link set $interface up
    ipc=$(ip addr show $interface | grep -Po 'inet \K[\d.]+')
    mac=$(ip link show $interface | grep link/ether | awk '{print $2}')
    key=$(openssl rand -hex 2)
    echo "IP    : $ipc"
    echo "MAC   : $mac"
    echo "KEY   : $key"
}

connect() {
    echo "Mencoba login ke WMS..."

    curl -X POST \
        --data-urlencode "username_=$username" \
        --data-urlencode "autologin_time=8600" \
        --data-urlencode "username=$username.$key@$type.$sid" \
        --data-urlencode "password=$password" \
        -H "accept: application/json, text/javascript, */*; q=0.01" \
		-H "accept-language: en-US,en;q=0.9,id;q=0.8" \
		-H "connection: keep-alive" \
		-H "content-type: application/x-www-form-urlencoded; charset=UTF-8" \
		-H "origin: https://welcome2.wifi.id" \
		-H "referer: https://welcome2.wifi.id/wms/?gw_id=$gw_id&client_mac=$mac&wlan=$wlan&sessionid=$sessionid" \
        -H 'sec-ch-ua: "Chromium";v="118", "Google Chrome";v="118", "Not=A?Brand";v="99"' \
        -H "sec-ch-ua-mobile: ?0" \
        -H "sec-ch-ua-platform: Linux" \
        -H "sec-fetch-dest: empty" \
        -H "sec-fetch-mode: cors" \
        -H "sec-fetch-site: same-origin" \
        -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36' \
        -H "x-requested-with: XMLHttpRequest" \
        "https://welcome2.wifi.id/wms/auth/authnew/autologin/quarantine.php?ipc=$ipc&gw_id=$gw_id&mac=$mac&redirect=&wlan=$wlan&landURL="
}

for i in {1..5}
do
    check
    sleep 10
done
