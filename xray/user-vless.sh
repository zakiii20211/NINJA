#!/bin/bash
#Script Check User Vless FULL MOD By KhaiVpn767
clear
red='\e[1;31m'
gr='\e[0;32m'
blue='\e[0;34m'
bb='\e[0;94m'
cy='\033[0;36m'
NC='\e[0m'

MYIP=$(wget -qO- ipv4.icanhazip.com)
domain=$(cat /etc/xray/domain)
dom=$domain
tls="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS TLS" | cut -d: -f2 | sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS NON TLS" | cut -d: -f2 | sed 's/ //g')"
xhttp="$(cat ~/log-install.txt | grep -w "XRAY VLESS XHTTP NON TLS" | cut -d: -f2 | sed 's/ //g')"

FILE="/usr/local/etc/xray/config.json"

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$FILE" 2>/dev/null)
if [[ ${NUMBER_OF_CLIENTS} == '0' ]] || [[ -z $NUMBER_OF_CLIENTS ]]; then
	clear
	echo -e "${red}════════════════${NC}"
	echo -e " CHECK XRAY VLESS CONFIG "
	echo -e "${red}════════════════${NC}"
	echo "Kau tak ada user VLESS lagi!"
	read -n 1 -s -r -p "Press any key to back on menu"
	menu
	exit 1
fi

clear
echo -e "${bb}════════════════${NC}"
echo -e " ${cy}CHECK XRAY VLESS CONFIG${bb} "
echo -e "════════════════${NC}"
echo ""
echo " No Expired User"
grep -E "^### " "$FILE" | cut -d ' ' -f 2-3 | nl -s ') '
echo ""
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER

user=$(grep -E "^### " "$FILE" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}p")
uuid=$(grep "email\": \"$user\"" "$FILE" | head -1 | cut -d '"' -f4)
exp=$(grep -E "^### " "$FILE" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}p")

clear
echo ""
read -p "Bug Address (Example: www.google.com) : " address
read -p "Bug SNI/Host (Example : m.facebook.com) : " hst
[[ $address == "" ]] && sts=$domain || sts=${address}.${domain}
[[ $hst == "" ]] && sni=$domain || sni=$hst

read -p "PATH (Enter untuk default /xvless) : " wss
[[ $wss == "" ]] && path="/xvless" || path="$wss"

vlesslink1="vless://${uuid}@${dom}:$tls?path=$path/xvless&security=tls&encryption=none&type=ws&sni=$sni#${user}"
vlesslink2="vless://${uuid}@${dom}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=$sni#${user}"
vlesslink3="vless://${uuid}@${dom}:$none?path=$path/xvless-hup&encryption=none&type=httpupgrade&host=$sni#${user}"
vlesslink4="vless://${uuid}@$dom:$xhttp?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=$dom#${user}"
vless_vision="vless://${uuid}@${dom}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=$sni#$user"
vlessgrpc="vless://${uuid}@${dom}:$tls?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgrpc&sni=$sni#$user"

digiboost="vless://${uuid}@162.159.133.61:$none?path=/xvlessntls&encryption=none&type=ws&host=cdn.opensignal.com.$dom#${user}-digi-boost-3mbps"
digiboost2="vless://${uuid}@opensignal.com.$dom:$none?path=/xvlessntls&encryption=none&type=ws#${user}-digi-boost-6/12mbps"
diginew="vless://${uuid}@172.66.169.187:$none?path=/xvlessntls&encryption=none&type=ws&host=speedtest.net.$dom#${user}-digi-new"

maxisviu="vless://${uuid}@help.viu.com.$dom:$none?path=/xvlessntls&encryption=none&type=ws&host=help.viu.com#${user}-maxis-viu"
maxisfrez="vless://${uuid}@auth.opensignal.com:$xhttp?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=cdn.opensignal.$dom#${user}-max-frez"

umobile3="vless://${uuid}@172.66.40.170:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-umobile-ws"
umopayload="vless://${uuid}@auth.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=strx-payload://u.com.my/#${user}-umo-hp"
umopayload2="vless://${uuid}@auth.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: u.com.my[crlf][crlf][split]CF-RAY /xvless-hup HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=httpupgrade&host=${domain}#${user}-umo-xlite"

yes="vless://${uuid}@104.17.147.22:$none?path=/vlessntls&encryption=none&type=ws&host=$dom#${user}-yes-router"
yoodopubg1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=m.pubgmobile.com#${user}-yodoopubg1"
yoodopokemon1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=community.pokemon.com#${user}-yodoopokemon1"
yoodoml1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=m.mobilelegends.com#${user}-yodooml1"

unifi1="vless://${uuid}@auth.opensignal.com:$none?path=/xvlessntls&encryption=none&type=ws&host=$domain#${user}-unifi-wow"
unifi2="vless://${uuid}@104.17.10.12:$none?path=/xvlessntls&encryption=none&type=ws&host=$domain#${user}-unifi-bebas"

systemctl restart xray >/dev/null 2>&1
systemctl restart xray@none >/dev/null 2>&1
systemctl restart xray@xhttp >/dev/null 2>&1

clear
echo -e ""
echo -e "================================="
echo -e " XRAY VLESS WS & XTLS "
echo -e "================================="
echo -e "Remarks : ${user}"
echo -e "Expired : $exp"
echo -e "IP/Host : ${MYIP}"
echo -e "Domain : ${domain}"
echo -e "Port TLS : $tls"
echo -e "Port NTLS : $none"
echo -e "Port XHTTP : $xhttp"
echo -e "ID : ${uuid}"
echo -e "================================="
echo -e "LINK VLESS TLS :"
echo -e "\`\`"
echo -e "${vlesslink1}"
echo -e "\`\`"
echo -e "================================="
echo -e "LINK VLESS NTLS : "
echo -e "\`\`\`"
echo -e "${vlesslink2}"
echo -e "\`\`"
echo -e "================================="
echo -e "LINK VLESS HTTPUPGRADE : "
echo -e "\`\`"
echo -e "${vlesslink3}"
echo -e "\`\`"
echo -e "================================="
echo -e "LINK VLESS XHTTP : "
echo -e "\`\`\`"
echo -e "${vlesslink4}"
echo -e "\`\`"
echo -e "================================="
echo -e "LINK VLESS XTLS VISION : "
echo -e "\`\`\`"
echo -e "${vless_vision}"
echo -e "\`\`"
echo -e "================================="
echo -e "LINK VLESS GRPC : "
echo -e "\`\`\`"
echo -e "${vlessgrpc}"
echo -e "\`\`\`"

echo -e " ${bb}═══════════════${NC} "
echo -e " \033[30;5;47m ⇱ TELCO CONFIG ⇲ \033[m"
echo -e " ${bb}═══════════════════════${NC} "
echo -e ""
echo -e "${cy}LINK VLESS DIGI BOOSTER 3MBPS :${NC} "
echo -e "\`\`"
echo -e "${digiboost}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI BOOSTER 6/12MBPS :${NC} "
echo -e "\`\`"
echo -e "${digiboost2}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI TANPA LANGGAN :${NC} "
echo -e "\`\`\`"
echo -e "${diginew}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS MAXIS-VIU :${NC} "
echo -e "\`\`\`"
echo -e "${maxisviu}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS MAXIS-FREZ-XHTTP :${NC} "
echo -e "\`\`\`"
echo -e "${maxisfrez}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD XLITE:${NC} "
echo -e "\`\`\`"
echo -e "${umopayload2}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD STRX:${NC} "
echo -e "\`\`\`"
echo -e "${umopayload}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE WEBSOCKET:${NC} "
echo -e "\`\`"
echo -e "${umobile3}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS YES4G :${NC} "
echo -e "\`\`\`"
echo -e "${yes}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO PUBG :${NC} "
echo -e "\`\`\`"
echo -e "${yoodopubg1}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO POKEMON :${NC} "
echo -e "\`\`"
echo -e "${yoodopokemon1}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO ML :${NC} "
echo -e "\`\`"
echo -e "${yoodoml1}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI WOW:${NC} "
echo -e "\`\`"
echo -e "${unifi1}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI BEBAS:${NC} "
echo -e "\`\`\`"
echo -e "${unifi2}"
echo -e "\`\`"
echo -e ""
echo -e "Script Mod By KhaiVpn767"
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu