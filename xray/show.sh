#!/bin/bash
clear
bb='\E[1;38;5;46m'
cy='\E[1;36m'
NC='\E[0m'

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/vless.txt")
[[ $NUMBER_OF_CLIENTS == 0 ]] && echo "Anda belum memiliki akun Vless" && exit 1

echo -e "\E[0;41;36m    SHOW VLESS TELCO CONFIG    \E[0m"
echo " Select client to view config"
echo " Press CTRL+C to return"
echo ""
grep -E "^### " "/usr/local/etc/xray/vless.txt" | cut -d' ' -f2-3 | nl -s ") "
echo ""
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
data=$(grep -E "^### " "/usr/local/etc/xray/vless.txt" | sed -n ${CLIENT_NUMBER}p)
user=$(awk '{print $2}' <<< $data)
exp=$(awk '{print $3}' <<< $data)
uuid=$(grep -w "$user" /usr/local/etc/xray/config.json | grep '"id"' | head -n1 | awk -F'"' '{print $4}')
dom=$(cat /usr/local/etc/xray/domain 2>/dev/null)
sni=$dom
MYIP=$(curl -s ipv4.icanhazip.com)
tls=$(grep "VLESS WS TLS" ~/log-install.txt | cut -d: -f2 | xargs)
none=$(grep "VLESS WS None TLS" ~/log-install.txt | cut -d: -f2 | xargs)
xhttp=$(grep "VLESS XHTTP" ~/log-install.txt | cut -d: -f2 | xargs)
created=$(grep -w "$user" /usr/local/etc/xray/vless.txt | awk '{print $3}')

# LINK STANDARD
vlesslink1="vless://$uuid@$dom:$tls?path=/xvless&security=tls&encryption=none&type=ws#$user"
vlesslink2="vless://$uuid@$dom:$none?path=/xvlessntls&encryption=none&type=ws#$user"
vlesslink3="vless://$uuid@$dom:$none?path=/xvless-hup&encryption=none&type=httpupgrade#$user"
vlesslink4="vless://$uuid@$dom:$xhttp?mode=auto&path=/xvless-xhttp-ntls&encryption=none&type=xhttp#$user"
vless_vision="vless://$uuid@$dom:$tls?security=tls&encryption=none&type=tcp&headerType=none&flow=xtls-rprx-vision#$user-VISION"
vlessgrpc="vless://$uuid@$dom:$tls?security=tls&encryption=none&type=grpc&serviceName=xvless-grpc&sni=$dom#$user-GRPC"

# LINK TELCO
digiboost="vless://$uuid@162.159.133.61:$none?path=/$user/xvlessntls&encryption=none&type=ws&host=cdn.opensignal.com.$dom#$user-DIGI-BOOST-3MB"
digiboost2="vless://$uuid@162.159.135.42:$none?path=/$user/xvlessntls&encryption=none&type=ws&host=cdn.cloudflare.net.$dom#$user-DIGI-BOOST-6-12MB"
diginew="vless://$uuid@$dom:$none?path=/digi-new&encryption=none&type=ws#$user-DIGI-NEW"
maxisviu="vless://$uuid@help.viu.com.$dom:$none?path=/$user/xvlessntls&encryption=none&type=ws&host=help.viu.com#$user-MAXIS-VIU"
maxisfrez="vless://$uuid@ads.maxis.com.my:$xhttp?mode=auto&path=/maxis-frez&encryption=none&type=xhttp#$user-MAXIS-FREZ"
umopayload2="vless://$uuid@172.66.40.170:$none?path=/$user/xlitem&encryption=none&type=ws&host=$dom#$user-U-XLITE"
umopayload="vless://$uuid@172.66.40.170:$none?path=/$user/strx&encryption=none&type=ws&host=$dom#$user-U-STRX"
umobile3="vless://$uuid@$dom:$none?path=/umobile-ws&encryption=none&type=ws#$user-U-WS"
yes="vless://$uuid@104.17.147.22:$none?path=/$user/vlessntls&encryption=none&type=ws&host=$dom#$user-YES4G"
yoodopubg1="vless://$uuid@104.21.32.1:$none?path=/pubg&encryption=none&type=ws&host=$dom#$user-YODOO-PUBG"
yoodopokemon1="vless://$uuid@104.21.32.1:$none?path=/pokemon&encryption=none&type=ws&host=$dom#$user-YODOO-PKM"
yoodoml1="vless://$uuid@104.21.32.1:$none?path=/ml&encryption=none&type=ws&host=$dom#$user-YODOO-ML"
unifi1="vless://$uuid@$dom:$none?path=/unifi-wow&encryption=none&type=ws#$user-UNIFI-WOW"
unifi2="vless://$uuid@$dom:$none?path=/unifi-bebas&encryption=none&type=ws#$user-UNIFI-BEBAS"

clear
echo -e "------------------[XRAY VLESS WS]-------------------"
echo -e "Remarks : ${user}"
echo -e "Domain : ${dom}"
echo -e "SNI : ${sni}"
echo -e "IP/Host : ${MYIP}"
echo -e "Port TLS : $tls"
echo -e "Port None TLS: $none"
echo -e "Port XHTTP : $xhttp"
echo -e "User ID : ${uuid}"
echo -e "Encryption : None"
echo -e "Created : $created"
echo -e "Expired : $exp"
echo -e "----------------------------------------------------"
echo -e "LINK VLESS TLS :"
echo -e '```'
echo -e "${vlesslink1}"
echo -e '```'
echo -e "================================="
echo -e "LINK VLESS NTLS : "
echo -e '```'
echo -e "${vlesslink2}"
echo -e '```'
echo -e "================================="
echo -e "LINK VLESS HTTPUPGRADE : "
echo -e '```'
echo -e "${vlesslink3}"
echo -e '```'
echo -e "================================="
echo -e "LINK VLESS XHTTP : "
echo -e '```'
echo -e "${vlesslink4}"
echo -e '```'
echo -e "================================="
echo -e "LINK VLESS XTLS : "
echo -e '```'
echo -e "${vless_vision}"
echo -e '```'
echo -e "================================="
echo -e "LINK VLESS GRPC : "
echo -e '```'
echo -e "${vlessgrpc}"
echo -e '```'
echo -e " ${bb}═══════════════${NC} "
echo -e " \033[30;5;47m ⇱ TELCO CONFIG ⇲ \033[m"
echo -e " ${bb}═══════════════${NC} "
echo -e "${cy}LINK VLESS DIGI BOOSTER 3MBPS :${NC} "
echo -e '```'
echo -e "${digiboost}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI BOOSTER 6/12MBPS :${NC} "
echo -e '```'
echo -e "${digiboost2}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI TANPA LANGGAN :${NC} "
echo -e '```'
echo -e "${diginew}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS MAXIS-VIU :${NC} "
echo -e '```'
echo -e "${maxisviu}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS MAXIS-FREZ-XHTTP :${NC} "
echo -e '```'
echo -e "${maxisfrez}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD XLITE:${NC} "
echo -e '```'
echo -e "${umopayload2}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD STRX:${NC} "
echo -e '```'
echo -e "${umopayload}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE WEBSOCKET:${NC} "
echo -e '```'
echo -e "${umobile3}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS YES4G :${NC} "
echo -e '```'
echo -e "${yes}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO PUBG :${NC} "
echo -e '```'
echo -e "${yoodopubg1}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO POKEMON :${NC} "
echo -e '```'
echo -e "${yoodopokemon1}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO ML :${NC} "
echo -e '```'
echo -e "${yoodoml1}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI WOW:${NC} "
echo -e '```'
echo -e "${unifi1}"
echo -e '```'
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI BEBAS:${NC} "
echo -e '```'
echo -e "${unifi2}"
echo -e '```'
echo -e "================================="
echo -e "◇━━━━━━━━━◇"
echo -e "    SILA COPY LINK DI ATAS"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "TELCO :"
echo -e "Remarks : ${user}"
echo -e "Domain : ${dom}"
echo -e "AKTIF : Day"
echo -e "Created : $created"
echo -e "Expired : $exp"
echo -e "◇━━━━━━━━━◇"
echo -e "id Anda : ${uuid}"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "ScriptMod By khaiVPN"
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu
EOF
chmod 755 /usr/bin/show