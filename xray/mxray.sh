#!/bin/bash
clear
red='\e[1;31m'
gr='\e[0;32m'
blue='\e[0;34m'
bb='\e[0;94m'
cy='\033[0;36m'
NC='\e[0m'
clear

MYIP=$(wget -qO- ipv4.icanhazip.com);
clear

domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "XRAY VLESS WS NON TLS" | cut -d: -f2|sed 's/ //g')"
xhttp="$(cat ~/log-install.txt | grep -w "XRAY VLESS XHTTP NON TLS" | cut -d: -f2|sed 's/ //g')"
hup="$(cat ~/log-install.txt | grep -w "XRAY VLESS HTTPUPG NON TLS" | cut -d: -f2|sed 's/ //g')"

xray_ok=$(systemctl is-active xray | grep -w "active" && echo -e "${gr}ON${NC}" || echo -e "${red}OFF${NC}")
none_ok=$(systemctl is-active xray@none | grep -w "active" && echo -e "${gr}ON${NC}" || echo -e "${red}OFF${NC}")
xhttp_ok=$(systemctl is-active xray@xhttp | grep -w "active" && echo -e "${gr}ON${NC}" || echo -e "${red}OFF${NC}")
usrvl=$(grep -c "^### " /usr/local/etc/xray/config.json)

add_user() {
	clear
	until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
	CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo "A client with the specified name was already created, please choose another name."
			sleep 1
            add_user
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
created=`date +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
read -p "SNI (bug) : " sni
read -p "PATH : " wss
path=$wss
read -p "Subdomain : " sub
dom=$sub$domain

sed -i '/#xray-vless-tls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-grpc$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-xtls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","flow": "xtls-rprx-vision","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-nontls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-nontls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-hup$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#vless-xhttp-tls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json
sed -i '/#vless-xhttp-ntls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json
echo -e "### $user $created $exp" $uuid >> /usr/local/etc/xray/vless.txt

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
umopayload="vless://${uuid}@auth.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1Host: [split]CF-RAY / HTTP/1.1Host: ${domain}Upgrade: websocket&encryption=none&type=ws&host=strx-payload://u.com.my/#${user}-umo-hp"
umopayload2="vless://${uuid}@auth.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1Host: u.com.my[split]CF-RAY /xvless-hup HTTP/1.1Host: ${domain}Upgrade: websocket&encryption=none&type=httpupgrade&host=${domain}#${user}-umo-xlite"
yes="vless://${uuid}@104.17.147.22:$none?path=/vlessntls&encryption=none&type=ws&host=$dom#${user}-yes-router"
yoodopubg1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=m.pubgmobile.com#${user}-yodoopubg1"
yoodopokemon1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=community.pokemon.com#${user}-yodoopokemon1"
yoodoml1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=m.mobilelegends.com#${user}-yodooml1"
unifi1="vless://${uuid}@auth.opensignal.com:$none?path=/xvlessntls&encryption=none&type=ws&host=$domain#${user}-unifi-wow"
unifi2="vless://${uuid}@104.17.10.12:$none?path=/xvlessntls&encryption=none&type=ws&host=$domain#${user}-unifi-bebas"

systemctl restart xray xray@none xray@xhttp
clear
echo -e "================================="
echo -e " XRAY VLESS WS & XTLS "
echo -e "================================="
echo -e "Remarks : ${user}"
echo -e "Created On : $created"
echo -e "Expired On : $exp"
echo -e "UUID : ${uuid}"
echo -e "================================="
echo -e "LINK VLESS TLS : \`\`${vlesslink1}\`\`"
echo -e "LINK VLESS NTLS : \`\`${vlesslink2}\`\`"
echo -e "LINK VLESS XTLS : \`\`${vless_vision}\`\`"
echo -e "LINK VLESS GRPC : \`\`${vlessgrpc}\`\`"
echo -e "LINK VLESS HTTPUPGRADE : \`\`${vlesslink3}\`\`"
echo -e "LINK VLESS XHTTP : \`\`${vlesslink4}\`\`"
echo -e "================================="
echo -e "${cy}TELCO CONFIG${NC}"
echo -e "DIGI 3MBPS : \`\`${digiboost}\`\`"
echo -e "DIGI 6/12MBPS : \`\`${digiboost2}\`\`"
echo -e "DIGI TANPA LANGGAN : \`\`${diginew}\`\`"
echo -e "MAXIS VIU : \`\`${maxisviu}\`\`"
echo -e "MAXIS FREZ XHTTP : \`\`${maxisfrez}\`\`"
echo -e "UMOBILE XLITE : \`\`${umopayload2}\`\`"
echo -e "UMOBILE STRX : \`\`${umopayload}\`\`"
echo -e "UMOBILE WS : \`\`${umobile3}\`\`"
echo -e "YES4G : \`\`${yes}\`\`"
echo -e "YODOO PUBG : \`\`${yoodopubg1}\`\`"
echo -e "YODOO POKEMON : \`\`${yoodopokemon1}\`\`"
echo -e "YODOO ML : \`\`${yoodoml1}\`\`"
echo -e "UNIFI WOW : \`\`${unifi1}\`\`"
echo -e "UNIFI BEBAS : \`\`${unifi2}\`\`"
echo -e "================================="
echo -e "${cy}Created On${NC} : $created"
echo -e "${cy}Expired On${NC} : $exp"
echo -e "${cy}UUID User${NC} : ${uuid}"
echo -e "================================="
echo -e "ScriptMod By khaiVPN"
read -n 1 -s -r -p "Press any key to back on menu"
mxray
}

add_uuid() {
clear
echo -e "${red}[ TAMBAH UUID PADA USER SEDIA ADA ]${NC}"
read -rp "Username: " user
CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} == '0' ]]; then echo "User tidak wujud"; sleep 1; mxray; fi

read -p "UUID baru [Enter untuk auto generate]: " uuid
if [ -z "$uuid" ]; then uuid=$(cat /proc/sys/kernel/random/uuid); fi
read -p "Expired (days): " masaaktif
created=`date +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
read -p "SNI (bug) : " sni
read -p "PATH : " wss
path=$wss
read -p "Subdomain : " sub
dom=$sub$domain

sed -i '/#xray-vless-tls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-grpc$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-xtls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","flow": "xtls-rprx-vision","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-nontls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-nontls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-hup$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#vless-xhttp-tls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json
sed -i '/#vless-xhttp-ntls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json
echo -e "### $user $created $exp" $uuid >> /usr/local/etc/xray/vless.txt

systemctl restart xray xray@none xray@xhttp
clear
echo -e "Berjaya tambah UUID baru untuk user: $user"
echo -e "Created On : $created"
echo -e "Expired On : $exp"
echo -e "UUID Baru : ${uuid}"
read -n 1 -s -r -p "Press any key to back on menu"
mxray
}

trial_user() {
uuid=$(cat /proc/sys/kernel/random/uuid)
user=TRIALvless-`</dev/urandom tr -dc X-Z0-9 | head -c4`
duration=1
created=`date +"%Y-%m-%d"`
exp=`date -d "$duration days" +"%Y-%m-%d"`
read -p "SNI (bug) : " sni
read -p "PATH : " wss
path=$wss
read -p "Subdomain : " sub
dom=$sub$domain
sed -i '/#xray-vless-tls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-grpc$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-xtls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","flow": "xtls-rprx-vision","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-nontls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-nontls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-hup$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#vless-xhttp-tls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json
sed -i '/#vless-xhttp-ntls$/a\### '"$user $created $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json
echo -e "### $user $created $exp" $uuid >> /usr/local/etc/xray/vless.txt
systemctl restart xray xray@none xray@xhttp
clear
echo -e "TRIAL VLESS BERJAYA"
echo -e "Username : $user"
echo -e "Created On : $created"
echo -e "Expired On : $exp"
echo -e "UUID : ${uuid}"
read -n 1 -s -r -p "Press any key to back on menu"
mxray
}

mxray() {
clear
echo -e " ${bb}═════════${NC}"
echo -e " \033[30;5;47m ⇱ MENU XRAY VLESS ⇲ \033[m"
echo -e " ${bb}═════════════════════════════════════════════════════════${NC} "
echo -e " "${cy}XRAY : ${NC}" $xray_ok "${cy}XRAY NONE : ${NC}" $none_ok "${cy}XRAY XHTTP : ${NC}" $xhttp_ok "${cy}TOTAL USER : ${NC}" $usrvl"
echo -e " ${bb}═════════════════════════════════════════════════════════════════${NC} "
echo -e " ${bb}[ 01 ]${NC} CREATE NEW USER ${bb}[ 05 ]${NC} CHECK USER LOGIN"
echo -e " ${bb}[ 02 ]${NC} CREATE TRIAL USER ${bb}[ 06 ]${NC} LIST USER"
echo -e " ${bb}[ 03 ]${NC} ADD UUID TO USER ${bb}[ 07 ]${NC} RENEW XRAY CERTIFICATION"
echo -e " ${bb}[ 04 ]${NC} DELETE ACTIVE USER ${bb}[ 08 ]${NC} CHANGE PORT XRAY"
echo -e " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e " ${bb}[ 0 ]${NC}" "${cy}EXIT TO MENU${NC} "
echo -e " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e " "
echo -e "\e[1;31m"
read -p " Please select an option : " mx
echo -e "\e[0m"
 case $mx in
 1) clear ; add_user ;;
 2) clear ; trial_user ;;
 3) clear ; add_uuid ;;
 4) clear ; del_user ;;
 5) clear ; check_user ;;
 6) clear ; user_list ;;
 7) clear ; recert_xray ;;
 8) clear ; mport-xray ;;
 0) sleep 0.5; clear; menu ;;
 *) echo -e "ERROR!! Please Enter an Correct Number"; sleep 1; clear; mxray ;;
 esac
}
mxray
