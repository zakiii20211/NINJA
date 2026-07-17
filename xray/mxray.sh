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

add_user() {
	clear
	until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			sleep 1
            add_user
		fi
	done
	
# === PILIH UUID ===
echo -e ""
echo -e "Pilih UUID untuk akaun $user:"
echo -e "1. Generate UUID Random Baru"
echo -e "2. Isi UUID Lama/Sendiri"
read -p "Pilihan [1-2]: " pilih_uuid
echo ""

if [[ $pilih_uuid == "2" ]]; then
	read -p "Masukkan UUID Lama: " uuid
else
	uuid=$(cat /proc/sys/kernel/random/uuid)
	echo "UUID Baru: $uuid"
fi
# === HABIS PILIH UUID ===

read -p "Expired (days): " masaaktif
created=`date +%Y-%m-%d` # <--- TAMBAH 1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
read -p "SNI (bug) : " sni
read -p "PATH (EXP : wss://bug.com /Press Enter If Only Use Default) : " wss
path=$wss
read -p "Subdomain (EXP : m.google.com. / Press Enter If Only Using Hosts) : " sub
dom=$sub$domain
sed -i '/#xray-vless-tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-grpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-xtls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","flow": "xtls-rprx-vision","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-nontls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-nontls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-hup$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#vless-xhttp-tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json
sed -i '/#vless-xhttp-ntls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json

echo -e "### $user $exp" $uuid >> /usr/local/etc/xray/vless.txt

vlesslink1="vless://${uuid}@${dom}:$tls?path=$path/xvless&security=tls&encryption=none&type=ws&sni=$sni#${user}"
vlesslink2="vless://${uuid}@${dom}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=$sni#${user}"
vlesslink3="vless://${uuid}@${dom}:$none?path=$path/xvless-hup&encryption=none&type=httpupgrade&host=$sni#${user}"
vlesslink4="vless://${uuid}@$dom:$xhttp?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=$dom#${user}"
vless_vision="vless://${uuid}@${dom}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=$sni#$user"
vlessgrpc="vless://${uuid}@${dom}:$tls?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgrpc&sni=$sni#$user"

#digisosial="vless://${uuid}@m.twitter.com.${domain}:$none?path=/xvlessntls&encryption=none&type=ws&host=m.twitter.com#${user}-digisosial"
#digiapn="vless://${uuid}@apn.jinnoe.eu.org:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-digi-apn"
#digiapn1="vless://${uuid}@protect.paymaya.com:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-digi-apn1"
digiboost="vless://${uuid}@162.159.133.61:$none?path=/xvlessntls&encryption=none&type=ws&host=cdn.opensignal.com.$dom#${user}-digi-boost-3mbps"
digiboost2="vless://${uuid}@opensignal.com.$dom:$none?path=/xvlessntls&encryption=none&type=ws#${user}-digi-boost-6/12mbps"
diginew="vless://${uuid}@172.66.169.187:$none?path=/xvlessntls&encryption=none&type=ws&host=speedtest.net.$dom#${user}-digi-new"


#maxisfrez="vless://${uuid}@cdn.opensignal.com:$none?path=/xvlessntls&encryption=none&type=ws&host=cdn.opensignal.com.$dom#${user}-maxistv-frez"
#maxistv1="vless://${uuid}@help.viu.com:$none?path=help.viu.com&encryption=none&type=ws&host=$dom#${user}-maxistv-hp"
#maxishunt1="vless://${uuid}@api-faceid.maxis.com.my.${domain}:$tls?security=xtls&encryption=none&headerType=none&type=tcp&flow=tls-rprx-vision&sni=www.mosti.gov.my#$user-maxisnew"
#maxishunt2="vless://${uuid}@api-faceid.maxis.com.my.${domain}:$tls?securuty=tls&path=/xvless&encryption=none&type=ws&host=www.mosti.gov.my&sni=www.mosti.gov.my#${user}-maxisnew1"
#maxishunt3="vless://${uuid}@api-faceid.maxis.com.my.${domain}:$none?path=/xvlessntls&encryption=none&type=ws&host=www.mosti.gov.my#${user}-maxisnew2"
#maxispayload="vless://${uuid}@siteintercept.qualtrics.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=strx-payload://mysejahtera.malaysia.gov.my/#${user}-max-and"
#maxispayload2="vless://${uuid}@siteintercept.qualtrics.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY /xvless-hup HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=httpupgrade&host=mysejahtera.malaysia.gov.my#${user}-max-xlite"
#maxisreborn="vless://${uuid}@zn4oa6cok9jkhgn6c-maxiscx.siteintercept.qualtrics.com:$none?encryption=none&type=ws&host=zn4oa6cok9jkhgn6c-maxiscx.siteintercept.qualtrics.com.$dom#${user}"
#maxissabah="vless://${uuid}@ookla.com:$tls?path=$path=/xvless&security=tls&encryption=none&host=$sni&type=ws&sni=$sni#${user}"
maxisviu="vless://${uuid}@help.viu.com.$dom:$none?path=/xvlessntls&encryption=none&type=ws&host=help.viu.com#${user}-maxis-viu"
maxisfrez="vless://${uuid}@auth.opensignal.com:$xhttp?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=cdn.opensignal.$dom#${user}-max-frez"
#maxisfrez2="vless://${uuid}@172.66.169.187:$none?path=/xvlessntls&encryption=none&type=ws&host=opensignal.com.$dom#${user}-maxis-frez"


#celcomboost="vless://${uuid}@104.17.147.22:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-celcomboost-router"
#celcomboost1="vless://${uuid}@www.speedtest.net:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-celcomboost-hp"
#celcomboost2="vless://${uuid}@104.17.148.22:$none?path=/xvlessntls&encryption=none&type=ws&host=cdn.opensignal.com.$dom#${user}-celcom-booster"
#celcomsedut="vless://${uuid}@nga.celcomdigi.com.$dom:$none?path=/xvlessntls&encryption=none&type=ws&host=nga.celcomdigi.com#${user}-celcom-sedut"
#celcomzero="vless://${uuid}@${dom}:8080?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=$sni#${user}-celcom-zero"

#umobile="vless://${uuid}@www.pubgmobile.com.${domain}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=www.pubgmobile.com#$user-umobile-funz"
#umobile1="vless://${uuid}@$MYIP:$none?path=/xvlessntls&encryption=none&type=ws&host=www.pubgmobile.com#${user}-umobile-funz-ntls"
#mobile2="vless://${uuid}@www.pubgmobile.com.${domain}:$tls?path=/xvless&security=tls&encryption=none&type=ws&sni=www.pubgmobile.com#${user}-umobile-funz-tls"
umobile3="vless://${uuid}@172.66.40.170:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-umobile-ws"
umopayload="vless://${uuid}@auth.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=strx-payload://u.com.my/#${user}-umo-hp"
#umopayload="vless://${uuid}@cdn.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: wap.u.com.my[crlf][crlf][split]STRX / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf]Sec-WebSocket-Key: K4vEMLAxh27PNePuLDwBAQ==[crlf]Connection: Upgrade[crlf]Sec-WebSocket-Version: 13[crlf][crlf]&encryption=none&type=ws&host=strx-payload://${domain}/#${user}-umo-hp"
#umopayload2="vless://${uuid}@cdn.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY /xvless-hup HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=httpupgrade&host=u.com.my#${user}-umo-xlite"
umopayload2="vless://${uuid}@auth.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: u.com.my[crlf][crlf][split]CF-RAY /xvless-hup HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=httpupgrade&host=${domain}#${user}-umo-xlite"


yes="vless://${uuid}@104.17.147.22:$none?path=/vlessntls&encryption=none&type=ws&host=$dom#${user}-yes-router"
#yes1="vless://${uuid}@eurohealthobservatory.who.int:$none?path=/vlessntlst&encryption=none&type=ws&host=$dom#${user}-yes-hp"

#yoodopubg="vless://${uuid}@m.pubgmobile.com.${domain}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=m.pubgmobile.com#$user-yodoopubg"
yoodopubg1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=m.pubgmobile.com#${user}-yodoopubg1"
#yoodopokemon="vless://${uuid}@community.pokemon.com.${domain}:$tls?security=xtls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=community.pokemon.com#$user-yodoopokemon"
yoodopokemon1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=community.pokemon.com#${user}-yodoopokemon1"

#yoodoml="vless://${uuid}@m.mobilelegends.com.${domain}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=m.mobilelegends.com#$user-yodooml"
yoodoml1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=m.mobilelegends.com#${user}-yodooml1"

#unifi="vless://${uuid}@map.unifi.com.my.${domain}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=map.unifi.com.my#$user-unifi"
#unifi1="vless://${uuid}@covidnow.pages.dev:$none?path=ws://$domain&encryption=none&type=ws&host=opensignal.com#${user}-unifi-wow"
unifi1="vless://${uuid}@auth.opensignal.com:$none?path=/xvlessntls&encryption=none&type=ws&host=$domain#${user}-unifi-wow"
unifi2="vless://${uuid}@104.17.10.12:$none?path=/xvlessntls&encryption=none&type=ws&host=$domain#${user}-unifi-bebas"

systemctl restart xray
systemctl restart xray@none
systemctl restart xray@xhttp

clear
echo -e ""
echo -e "================================="
echo -e "   XRAY VLESS WS & XTLS       " 
echo -e "================================="
echo -e "Remarks             : ${user}"
echo -e "Created             : $created"
echo -e "Expired On          : $exp"
echo -e "IP/Host             : ${MYIP}"
echo -e "Domain              : ${domain}"
echo -e "port TLS            : $tls"
echo -e "port none TLS       : $none"
echo -e "port xhttp none TLS : $xhttp"
echo -e "id                  : ${uuid}"
echo -e "Encryption          : none"
echo -e "network             : ws/httpupgrade/xhttp"
echo -e "path ws             : multipath"
echo -e "path httpupgrade    : /xvless-hup"
echo -e "path xhttp          : /xvless-xhttp-ntls"
echo -e "================================="
echo -e "LINK VLESS TLS :"
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlesslink1}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "LINK VLESS NTLS : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlesslink2}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "LINK VLESS XTLS : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vless_vision}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "LINK VLESS GRPC : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlessgrpc}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "LINK VLESS HTTPUPGRADE : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlesslink3}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e ""
echo -e ""
echo -e "LINK VLESS XHTTP : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlesslink4}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e ""
echo -e ""
echo -e " ${bb}═══════════════════════${NC} "
echo -e " \033[30;5;47m ⇱ TELCO CONFIG ⇲  \033[m"
echo -e " ${bb}═══════════════════════${NC} "
echo -e ""
echo -e ""
echo -e "${cy}LINK VLESS DIGI BOOSTER 3MBPS :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e ""
#echo -e "   \`${digiapn}\`"
#echo -e ""
#echo -e "   \`${digiapn1}\`"
#echo -e ""
echo -e "${digiboost}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
#echo -e "   \`${digisosial}\`"
#echo -e ""
#echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI BOOSTER 6/12MBPS :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${digiboost2}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI TANPA LANGGAN :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${diginew}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS-FREZ :${NC} "
echo -e ""
echo -e ""
#echo -e "\`\`\`"
#echo -e "${maxisfrez}"
#echo -e "\`\`\`"
#echo -e "   ${maxishunt2}"
#echo -e ""
#echo -e "   ${maxishunt3}"
#echo -e ""
#echo -e "================================="
echo -e "${cy}LINK VLESS MAXIS-VIU :${NC} "
#echo -e ""
echo -e "\`\`\`"
echo -e "${maxisviu}"
echo -e "\`\`\`"
#echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS PAYLOAD XLITE :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${maxispayload2}"
#echo -e "\`\`\`"
#echo -e ""
#echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS PAYLOAD STRX :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${maxispayload}"
#echo -e "\`\`\`"
#echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS SABAH :${NC} "
#echo -e ""
#echo -e "   \`${maxissabah}\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS MAXIS-FREZ-XHTTP :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${maxisfrez}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS-FREZ-WS :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${maxisfrez2}"
#echo -e "\`\`\`"
#echo -e ""
#echo -e ""
echo -e "================================="
#echo -e "${cy}LINK VLESS CELCOM-BOOSTER :${NC} "
#echo -e ""
#echo -e ""
#echo -e "   \`${celcomboost}\`"
#echo -e ""
#echo -e ""
#echo -e "   \`${celcomboost1}\`"
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${celcomboost2}"
#echo -e "\`\`\`"
#echo -e ""
#echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS CELCOM-SEDUT BASIC :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${celcomsedut}"
#echo -e "\`\`\`"
echo -e ""
echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS CELCOM-BASIC ZERO :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${celcomzero}"
#echo -e "\`\`\`"
#echo -e ""
#echo -e ""
#echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD XLITE:${NC} "
#echo -e ""
#echo -e ""
#echo -e "   \`${umobile}\`"
#echo -e ""
#echo -e ""
#echo -e "   \`${umobile1}\`"
#echo -e ""
#echo -e ""
#echo -e "   \`${umobile2}\`"
#echo -e ""
#echo -e ""
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${umopayload2}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD STRX:${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${umopayload}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE WEBSOCKET:${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${umobile3}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS YES4G :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${yes}"
echo -e "\`\`\`"
#echo -e "   \`${yes1}\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO PUBG :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e "\`\`\`${yoodopubg}"
#echo -e "\`\`\`"
#echo -e ""
echo -e "${yoodopubg1}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO POKEMON :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e "\`\`\`${yoodopokemon}"
#echo -e "\`\`\`"
#echo -e ""
echo -e "${yoodopokemon1}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO ML :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e "\`\`\`${yoodoml}"
#echo -e "\`\`\`"
#echo -e ""
echo -e "${yoodoml1}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI WOW:${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e "   ${unifi}"
#echo -e ""
echo -e "${unifi1}"
echo -e "\`\`\`"
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI BEBAS:${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${unifi2}"
echo -e "\`\`\`"
echo -e ""
echo -e "================================="
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "    SILA COPY LINK DI ATAS"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "TELCO :"
echo -e "Remarks : ${user}"
echo -e "Domain : ${domain}"
echo -e "AKTIF : Day"
echo -e "Created : $created" # <--- TAMBAH 2
echo -e "Expired : $exp"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "id Anda : ${uuid}"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "ScriptMod By khaiVPN"
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu
}

trial_user() {

uuid=$(cat /proc/sys/kernel/random/uuid)
user=TRIALvless-`</dev/urandom tr -dc X-Z0-9 | head -c4`
duration=1
# === PILIH UUID ===
echo -e ""
echo -e "Pilih UUID untuk akaun $user:"
echo -e "1. Generate UUID Random Baru"
echo -e "2. Isi UUID Lama/Sendiri"
read -p "Pilihan [1-2]: " pilih_uuid
echo ""

if [[ $pilih_uuid == "2" ]]; then
	read -p "Masukkan UUID Lama: " uuid
else
	uuid=$(cat /proc/sys/kernel/random/uuid)
	echo "UUID Baru: $uuid"
fi
# === HABIS PILIH UUID ===
exp=`date -d "$duration days" +"%Y-%m-%d"`
read -p "SNI (bug) : " sni
read -p "PATH (EXP : wss://bug.com /Press Enter If Only Use Default) : " wss
path=$wss
read -p "Subdomain (EXP : m.google.com. / Press Enter If Only Using Hosts) : " sub
dom=$sub$domain
sed -i '/#xray-vless-tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-grpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-vless-xtls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","flow": "xtls-rprx-vision","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#xray-nontls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-nontls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#xray-vless-hup$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/none.json
sed -i '/#vless-xhttp-tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json
sed -i '/#vless-xhttp-ntls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/xhttp.json

echo -e "### $user $exp" $uuid >> /usr/local/etc/xray/vless.txt

vlesslink1="vless://${uuid}@${dom}:$tls?path=$path/xvless&security=tls&encryption=none&type=ws&sni=$sni#${user}"
vlesslink2="vless://${uuid}@${dom}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=$sni#${user}"
vlesslink3="vless://${uuid}@${dom}:$none?path=$path/xvless-hup&encryption=none&type=httpupgrade&host=$sni#${user}"
vlesslink4="vless://${uuid}@$dom:$xhttp?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=$dom#${user}"
vless_vision="vless://${uuid}@${dom}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=$sni#$user"
vlessgrpc="vless://${uuid}@${dom}:$tls?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgrpc&sni=$sni#$user"

#digisosial="vless://${uuid}@m.twitter.com.${domain}:$none?path=/xvlessntls&encryption=none&type=ws&host=m.twitter.com#${user}-digisosial"
#digiapn="vless://${uuid}@apn.jinnoe.eu.org:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-digi-apn"
#digiapn1="vless://${uuid}@protect.paymaya.com:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-digi-apn1"
digiboost="vless://${uuid}@162.159.133.61:$none?path=/xvlessntls&encryption=none&type=ws&host=cdn.opensignal.com.$dom#${user}-digi-boost-3mbps"
digiboost2="vless://${uuid}@opensignal.com.$dom:$none?path=/xvlessntls&encryption=none&type=ws#${user}-digi-boost-6/12mbps"
diginew="vless://${uuid}@172.66.169.187:$none?path=/xvlessntls&encryption=none&type=ws&host=speedtest.net.$dom#${user}-digi-new"


#maxisfrez="vless://${uuid}@cdn.opensignal.com:$none?path=/xvlessntls&encryption=none&type=ws&host=cdn.opensignal.com.$dom#${user}-maxistv-frez"
#maxistv1="vless://${uuid}@help.viu.com:$none?path=help.viu.com&encryption=none&type=ws&host=$dom#${user}-maxistv-hp"
#maxishunt1="vless://${uuid}@api-faceid.maxis.com.my.${domain}:$tls?security=xtls&encryption=none&headerType=none&type=tcp&flow=tls-rprx-vision&sni=www.mosti.gov.my#$user-maxisnew"
#maxishunt2="vless://${uuid}@api-faceid.maxis.com.my.${domain}:$tls?securuty=tls&path=/xvless&encryption=none&type=ws&host=www.mosti.gov.my&sni=www.mosti.gov.my#${user}-maxisnew1"
#maxishunt3="vless://${uuid}@api-faceid.maxis.com.my.${domain}:$none?path=/xvlessntls&encryption=none&type=ws&host=www.mosti.gov.my#${user}-maxisnew2"
#maxispayload="vless://${uuid}@siteintercept.qualtrics.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=strx-payload://mysejahtera.malaysia.gov.my/#${user}-max-and"
#maxispayload2="vless://${uuid}@siteintercept.qualtrics.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY /xvless-hup HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=httpupgrade&host=mysejahtera.malaysia.gov.my#${user}-max-xlite"
#maxisreborn="vless://${uuid}@zn4oa6cok9jkhgn6c-maxiscx.siteintercept.qualtrics.com:$none?encryption=none&type=ws&host=zn4oa6cok9jkhgn6c-maxiscx.siteintercept.qualtrics.com.$dom#${user}"
#maxissabah="vless://${uuid}@ookla.com:$tls?path=$path=/xvless&security=tls&encryption=none&host=$sni&type=ws&sni=$sni#${user}"
maxisviu="vless://${uuid}@help.viu.com.$dom:$none?path=/xvlessntls&encryption=none&type=ws&host=help.viu.com#${user}-maxis-viu"
maxisfrez="vless://${uuid}@auth.opensignal.com:$xhttp?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=cdn.opensignal.$dom#${user}-max-frez"
#maxisfrez2="vless://${uuid}@172.66.169.187:$none?path=/xvlessntls&encryption=none&type=ws&host=opensignal.com.$dom#${user}-maxis-frez"


#celcomboost="vless://${uuid}@104.17.147.22:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-celcomboost-router"
#celcomboost1="vless://${uuid}@www.speedtest.net:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-celcomboost-hp"
#celcomboost2="vless://${uuid}@104.17.148.22:$none?path=/xvlessntls&encryption=none&type=ws&host=cdn.opensignal.com.$dom#${user}-celcom-booster"
#celcomsedut="vless://${uuid}@nga.celcomdigi.com.$dom:$none?path=/xvlessntls&encryption=none&type=ws&host=nga.celcomdigi.com#${user}-celcom-sedut"
#celcomzero="vless://${uuid}@${dom}:8080?mode=auto&path=$path/xvless-xhttp-ntls&encryption=none&type=xhttp&host=$sni#${user}-celcom-zero"

#umobile="vless://${uuid}@www.pubgmobile.com.${domain}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=www.pubgmobile.com#$user-umobile-funz"
#umobile1="vless://${uuid}@$MYIP:$none?path=/xvlessntls&encryption=none&type=ws&host=www.pubgmobile.com#${user}-umobile-funz-ntls"
#mobile2="vless://${uuid}@www.pubgmobile.com.${domain}:$tls?path=/xvless&security=tls&encryption=none&type=ws&sni=www.pubgmobile.com#${user}-umobile-funz-tls"
umobile3="vless://${uuid}@172.66.40.170:$none?path=/xvlessntls&encryption=none&type=ws&host=$dom#${user}-umobile-ws"
umopayload="vless://${uuid}@auth.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=ws&host=strx-payload://u.com.my/#${user}-umo-hp"
#umopayload="vless://${uuid}@cdn.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: wap.u.com.my[crlf][crlf][split]STRX / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf]Sec-WebSocket-Key: K4vEMLAxh27PNePuLDwBAQ==[crlf]Connection: Upgrade[crlf]Sec-WebSocket-Version: 13[crlf][crlf]&encryption=none&type=ws&host=strx-payload://${domain}/#${user}-umo-hp"
#umopayload2="vless://${uuid}@cdn.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: [host][crlf][crlf][split]CF-RAY /xvless-hup HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=httpupgrade&host=u.com.my#${user}-umo-xlite"
umopayload2="vless://${uuid}@auth.opensignal.com:$none?path=GET /cdn-cgi/trace HTTP/1.1[crlf]Host: u.com.my[crlf][crlf][split]CF-RAY /xvless-hup HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]&encryption=none&type=httpupgrade&host=${domain}#${user}-umo-xlite"


yes="vless://${uuid}@104.17.147.22:$none?path=/vlessntls&encryption=none&type=ws&host=$dom#${user}-yes-router"
#yes1="vless://${uuid}@eurohealthobservatory.who.int:$none?path=/vlessntlst&encryption=none&type=ws&host=$dom#${user}-yes-hp"

#yoodopubg="vless://${uuid}@m.pubgmobile.com.${domain}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=m.pubgmobile.com#$user-yodoopubg"
yoodopubg1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=m.pubgmobile.com#${user}-yodoopubg1"
#yoodopokemon="vless://${uuid}@community.pokemon.com.${domain}:$tls?security=xtls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=community.pokemon.com#$user-yodoopokemon"
yoodopokemon1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=community.pokemon.com#${user}-yodoopokemon1"

#yoodoml="vless://${uuid}@m.mobilelegends.com.${domain}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=m.mobilelegends.com#$user-yodooml"
yoodoml1="vless://${uuid}@${MYIP}:$none?path=$path/xvlessntls&encryption=none&type=ws&host=m.mobilelegends.com#${user}-yodooml1"

#unifi="vless://${uuid}@map.unifi.com.my.${domain}:$tls?security=tls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-vision&sni=map.unifi.com.my#$user-unifi"
#unifi1="vless://${uuid}@covidnow.pages.dev:$none?path=ws://$domain&encryption=none&type=ws&host=opensignal.com#${user}-unifi-wow"
unifi1="vless://${uuid}@auth.opensignal.com:$none?path=/xvlessntls&encryption=none&type=ws&host=$domain#${user}-unifi-wow"
unifi2="vless://${uuid}@104.17.10.12:$none?path=/xvlessntls&encryption=none&type=ws&host=$domain#${user}-unifi-bebas"

systemctl restart xray
systemctl restart xray@none
systemctl restart xray@xhttp

clear
echo -e ""
echo -e "================================="
echo -e "   XRAY VLESS WS & XTLS       " 
echo -e "================================="
echo -e "Remarks             : ${user}"
echo -e "Created             : $created"
echo -e "Expired On          : $exp"
echo -e "IP/Host             : ${MYIP}"
echo -e "Domain              : ${domain}"
echo -e "port TLS            : $tls"
echo -e "port none TLS       : $none"
echo -e "port xhttp none TLS : $xhttp"
echo -e "id                  : ${uuid}"
echo -e "Encryption          : none"
echo -e "network             : ws/httpupgrade/xhttp"
echo -e "path ws             : multipath"
echo -e "path httpupgrade    : /xvless-hup"
echo -e "path xhttp          : /xvless-xhttp-ntls"
echo -e "================================="
echo -e "LINK VLESS TLS :"
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlesslink1}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "LINK VLESS NTLS : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlesslink2}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "LINK VLESS XTLS : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vless_vision}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "LINK VLESS GRPC : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlessgrpc}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "LINK VLESS HTTPUPGRADE : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlesslink3}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e ""
echo -e ""
echo -e "LINK VLESS XHTTP : "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${vlesslink4}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e ""
echo -e ""
echo -e " ${bb}═══════════════════════${NC} "
echo -e " \033[30;5;47m ⇱ TELCO CONFIG ⇲  \033[m"
echo -e " ${bb}═══════════════════════${NC} "
echo -e ""
echo -e ""
echo -e "${cy}LINK VLESS DIGI BOOSTER 3MBPS :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e ""
#echo -e "   \`${digiapn}\`"
#echo -e ""
#echo -e "   \`${digiapn1}\`"
#echo -e ""
echo -e "${digiboost}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
#echo -e "   \`${digisosial}\`"
#echo -e ""
#echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI BOOSTER 6/12MBPS :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${digiboost2}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI TANPA LANGGAN :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${diginew}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS-FREZ :${NC} "
echo -e ""
echo -e ""
#echo -e "\`\`\`"
#echo -e "${maxisfrez}"
#echo -e "\`\`\`"
#echo -e "   ${maxishunt2}"
#echo -e ""
#echo -e "   ${maxishunt3}"
#echo -e ""
#echo -e "================================="
echo -e "${cy}LINK VLESS MAXIS-VIU :${NC} "
#echo -e ""
echo -e "\`\`\`"
echo -e "${maxisviu}"
echo -e "\`\`\`"
#echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS PAYLOAD XLITE :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${maxispayload2}"
#echo -e "\`\`\`"
#echo -e ""
#echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS PAYLOAD STRX :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${maxispayload}"
#echo -e "\`\`\`"
#echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS SABAH :${NC} "
#echo -e ""
#echo -e "   \`${maxissabah}\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS MAXIS-FREZ-XHTTP :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${maxisfrez}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS MAXIS-FREZ-WS :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${maxisfrez2}"
#echo -e "\`\`\`"
#echo -e ""
#echo -e ""
echo -e "================================="
#echo -e "${cy}LINK VLESS CELCOM-BOOSTER :${NC} "
#echo -e ""
#echo -e ""
#echo -e "   \`${celcomboost}\`"
#echo -e ""
#echo -e ""
#echo -e "   \`${celcomboost1}\`"
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${celcomboost2}"
#echo -e "\`\`\`"
#echo -e ""
#echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS CELCOM-SEDUT BASIC :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${celcomsedut}"
#echo -e "\`\`\`"
echo -e ""
echo -e ""
#echo -e "================================="
#echo -e "${cy}LINK VLESS CELCOM-BASIC ZERO :${NC} "
#echo -e ""
#echo -e ""
#echo -e "\`\`\`"
#echo -e "${celcomzero}"
#echo -e "\`\`\`"
#echo -e ""
#echo -e ""
#echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD XLITE:${NC} "
#echo -e ""
#echo -e ""
#echo -e "   \`${umobile}\`"
#echo -e ""
#echo -e ""
#echo -e "   \`${umobile1}\`"
#echo -e ""
#echo -e ""
#echo -e "   \`${umobile2}\`"
#echo -e ""
#echo -e ""
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${umopayload2}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD STRX:${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${umopayload}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE WEBSOCKET:${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${umobile3}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS YES4G :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${yes}"
echo -e "\`\`\`"
#echo -e "   \`${yes1}\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO PUBG :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e "\`\`\`${yoodopubg}"
#echo -e "\`\`\`"
#echo -e ""
echo -e "${yoodopubg1}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO POKEMON :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e "\`\`\`${yoodopokemon}"
#echo -e "\`\`\`"
#echo -e ""
echo -e "${yoodopokemon1}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO ML :${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e "\`\`\`${yoodoml}"
#echo -e "\`\`\`"
#echo -e ""
echo -e "${yoodoml1}"
echo -e "\`\`\`"
echo -e ""
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI WOW:${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
#echo -e "   ${unifi}"
#echo -e ""
echo -e "${unifi1}"
echo -e "\`\`\`"
echo -e ""
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI BEBAS:${NC} "
echo -e ""
echo -e ""
echo -e "\`\`\`"
echo -e "${unifi2}"
echo -e "\`\`\`"
echo -e ""
echo -e "================================="
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "    SILA COPY LINK DI ATAS"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "TELCO :"
echo -e "Remarks : ${user}"
echo -e "Domain : ${domain}"
echo -e "AKTIF : Day"
echo -e "Created : $created" # <--- TAMBAH 2
echo -e "Expired : $exp"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "id Anda : ${uuid}"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "ScriptMod By khaiVPN"
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu
}

renew_user() {
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/vless.txt")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		clear
		echo ""
		echo "You have no existing clients!"
		sleep 1
		mxray
	fi

	clear
	echo ""
	echo " Client Vless renew"
	echo " Press CTRL+C to return"
	echo -e "==============================="
	grep -E "^### " "/usr/local/etc/xray/vless.txt" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
read -p "Expired (Days): " masaaktif

user=$(grep -E "^### " "/usr/local/etc/xray/vless.txt" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/vless.txt" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### $user $exp/### $user $exp4/g" /usr/local/etc/xray/config.json
sed -i "s/### $user $exp/### $user $exp4/g" /usr/local/etc/xray/none.json
sed -i "s/### $user $exp/### $user $exp4/g" /usr/local/etc/xray/xhttp.json
sed -i "s/### $user $exp/### $user $exp4/g" /usr/local/etc/xray/vless.txt


systemctl restart xray
systemctl restart xray@none
systemctl restart xray@xhttp

clear
echo ""
echo "==============================="
echo "    Vless Account Renewed  "
echo "==============================="
echo " Username  : $user"
echo " Expired   : $exp4"
echo "==============================="
echo -e "ScriptMod By khaiVPN"
read -n 1 -s -r -p "Press any key to back on menu"
 menu
}

del_user() {
	NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/vless.txt")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo ""
		echo "You have no existing clients!"
		sleep 1
		mxray
	fi

	clear
	echo ""
	echo " Select the existing client you want to remove"
	echo " Press CTRL+C to return"
	echo " ==============================="
	echo "     No  Expired   User"
	grep -E "^### " "/usr/local/etc/xray/vless.txt" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
user=$(grep -E "^### " "/usr/local/etc/xray/vless.txt" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/usr/local/etc/xray/vless.txt" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/\b$user\b/d" /usr/local/etc/xray/vless.txt
sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/none.json
sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/xhttp.json
sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/vless.txt

systemctl restart xray
systemctl restart xray@none
systemctl restart xray@xhttp


clear
echo " Vless Account Deleted Successfully"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp"
echo " =========================="
echo -e "ScriptMod By khaiVPN"
read -n 1 -s -r -p "Press any key to back on menu"
 menu
}

check_user() {
echo -n > /tmp/other.txt
data=( `cat /usr/local/etc/xray/vless.txt | cut -d ' ' -f 2`);
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \E[0;47;30m     XRAY VLESS USER LOGIN      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi
echo -n > /tmp/ipvless.txt
data2=( `cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 4 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${data2[@]}"
do
jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 4 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipvless.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipvless.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done
jum=$(cat /tmp/ipvless.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
jum2=$(cat /tmp/ipvless.txt | nl)
echo "User : $akun";
echo "$jum2";
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi
rm -rf /tmp/ipvless.txt
rm -rf /tmp/other.txt
done
echo ""
echo ""
echo -e "ScriptMod By khaiVPN"
read -n 1 -s -r -p "Press any key to back on menu"
 menu
}

recert_xray() {
echo -e "============================================="
echo -e " ${gr} RECERT XRAY${NC}"
echo -e "============================================="
sleep 1
echo start
sleep 0.5
domain=$(cat /etc/xray/domain)
systemctl stop xray
systemctl stop xray@none
systemctl stop xray@xhttp

sudo kill -9 $(sudo lsof -t -i:80)
~/.acme.sh/acme.sh --renew -d $domain --standalone -k ec-256 --force --ecc
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc
systemctl daemon-reload
systemctl restart xray
systemctl restart xray@none
systemctl restart xray@xhttp

echo Done
sleep 0.5
clear
echo -e "============================================="
echo -e " ${gr} RECERT DOMAIN SELESAI${NC}"
echo -e "============================================="
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
 menu
}

user_list() {
	NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/vless.txt")
        if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
                clear
                echo ""
                echo "You have no existing clients!"
                sleep 1
        fi

        clear
        echo -e "==============================="
        echo " VLESS USER LIST"
        echo -e "==============================="
        echo ""
        grep -E "^### " "/usr/local/etc/xray/vless.txt" | cut -d ' ' -f 2-4 | nl -s ') '
        echo " "
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu
}

show_config() {
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/usr/local/etc/xray/vless.txt")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo "You have no existing clients!"
sleep 1
mxray
fi
clear
echo "=================================="
echo " SHOW CONFIG VLESS WEBSOCKET"
echo "=================================="
echo ""
grep -E "^### " "/usr/local/etc/xray/vless.txt" | awk '{print NR") "$2" Exp: "$3}'
echo ""
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
done

data=$(grep -E "^### " "/usr/local/etc/xray/vless.txt" | sed -n ${CLIENT_NUMBER}p)
jum=$(echo $data | awk '{print NF}')

user=$(echo $data | awk '{print $2}')
exp=$(echo $data | awk '{print $3}')
created=$(echo $data | awk '{print $4}')
uuid=$(echo $data | awk '{print $5}')
if [[ $jum -ge 6 ]]; then sni=$(echo $data | awk '{print $6}'); else sni=$domain; fi
if [[ $jum -ge 7 ]]; then path=$(echo $data | awk '{print $7}'); else path=""; fi  
if [[ $jum -ge 8 ]]; then sub=$(echo $data | awk '{print $8}'); else sub=""; fi

[[ -z "$sni" ]] && sni=$domain
[[ -z "$path" ]] && path=""
[[ -z "$sub" ]] && sub=""

dom=$sub$domain

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
echo -e "\`\`\`"
echo -e "${vlesslink1}"
echo -e "\`\`"
echo -e "================================="
echo -e "LINK VLESS NTLS : "
echo -e "\`\`\`"
echo -e "${vlesslink2}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "LINK VLESS HTTPUPGRADE : "
echo -e "\`\`"
echo -e "${vlesslink3}"
echo -e "\`\`"
echo -e "================================="
echo -e "LINK VLESS XHTTP : "
echo -e "\`\`"
echo -e "${vlesslink4}"
echo -e "\`\`"
echo -e "================================="
echo -e "LINK VLESS XTLS : "
echo -e "\`\`\`"
echo -e "${vless_vision}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "LINK VLESS GRPC : "
echo -e "\`\`"
echo -e "${vlessgrpc}"
echo -e "\`\`"
echo -e " ${bb}═══════════════════════${NC} "
echo -e " \033[30;5;47m ⇱ TELCO CONFIG ⇲ \033[m"
echo -e " ${bb}═══════════════════════${NC} "
echo -e "${cy}LINK VLESS DIGI BOOSTER 3MBPS :${NC} "
echo -e "\`\`"
echo -e "${digiboost}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS DIGI BOOSTER 6/12MBPS :${NC} "
echo -e "\`\`\`"
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
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD XLITE:${NC} "
echo -e "\`\`\`"
echo -e "${umopayload2}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE PAYLOAD STRX:${NC} "
echo -e "\`\`\`"
echo -e "${umopayload}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UMOBILE WEBSOCKET:${NC} "
echo -e "\`\`"
echo -e "${umobile3}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS YES4G :${NC} "
echo -e "\`\`\`"
echo -e "${yes}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO PUBG :${NC} "
echo -e "\`\`"
echo -e "${yoodopubg1}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO POKEMON :${NC} "
echo -e "\`\`\`"
echo -e "${yoodopokemon1}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS YODOO ML :${NC} "
echo -e "\`\`"
echo -e "${yoodoml1}"
echo -e "\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI WOW:${NC} "
echo -e "\`\`\`"
echo -e "${unifi1}"
echo -e "\`\`\`"
echo -e "================================="
echo -e "${cy}LINK VLESS UNIFI BEBAS:${NC} "
echo -e "\`\`"
echo -e "${unifi2}"
echo -e "\`\`"
echo -e "================================="
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "    SILA COPY LINK DI ATAS"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "TELCO :"
echo -e "Remarks : ${user}"
echo -e "Domain : ${dom}"
echo -e "AKTIF : Day"
echo -e "Created : $created" # <--- TAMBAH 2
echo -e "Expired : $exp"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "id Anda : ${uuid}"
echo -e "◇━━━━━━━━━━━━━━━━━◇"
echo -e "ScriptMod By khaiVPN"
read -n 1 -s -r -p "Press any key to back on menu"
clear
menu
}

status="$(systemctl show xray --no-page)"                                 
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)                     
if [ "${status_text}" == "active" ]                                                     
then                                                                                    
xray_ok=""$gr"ON"$NC""             
else                                                                                    
xray_xok=""$red"OFF"$NC""    
fi 

status="$(systemctl show xray@none --no-page)"                                 
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)                     
if [ "${status_text}" == "active" ]                                                     
then                                                                                    
none_ok=""$gr"ON"$NC""             
else                                                                                    
none_xok=""$red"OFF"$NC""    
fi 

status="$(systemctl show xray@xhttp --no-page)"                                 
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)                     
if [ "${status_text}" == "active" ]                                                     
then                                                                                    
xhttp_ok=""$gr"ON"$NC""             
else                                                                                    
xhttp_xok=""$red"OFF"$NC""    
fi 

usrvl="$gr$(grep -o -i "###" /usr/local/etc/xray/vless.txt | wc -l)$NC"


echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " \033[30;5;47m                      ⇱ MENU XRAY VLESS ⇲                        \033[m"       
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC} " 
echo -e  " "   "" ${cy}XRAY : ${NC}" $xray_ok $xray_xok" ${cy}XRAY NONE : ${NC}" $none_ok $none_xok" ${cy}XRAY XHTTP : ${NC}" $xhttp_ok $xhttp_xok" ${cy}TOTAL USER : ${NC}" $usrvl"
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC} "       
echo -e  " ${bb}[ 01 ]${NC} CREATE NEW USER            ${bb}[ 05 ]${NC}"" CHECK USER LOGIN"
echo -e  " ${bb}[ 02 ]${NC} CREATE TRIAL USER          ${bb}[ 06 ]${NC}"" LIST USER"
echo -e  " ${bb}[ 03 ]${NC} EXTEND ACCOUNT ACTIVE      ${bb}[ 07 ]${NC}"" RENEW XRAY CERTIFICATION"
echo -e  " ${bb}[ 04 ]${NC} DELETE ACTIVE USER         ${bb}[ 08 ]${NC}"" CHANGE PORT XRAY"
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}" 
echo -e  " ${bb}[ 09 ]${NC} SHOW CONFIG VLESS   "
echo -e  " ${bb}[  0 ]${NC}" "${cy}EXIT TO MENU${NC}  "
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e  "  "
echo -e "\e[1;31m"
read -p  "     Please select an option :  " mx
echo -e "\e[0m"
 case $mx in
  1)
	clear ; add_user
  ;;
  2)
    clear ; trial_user
  ;;
  3)
    clear ; renew_user
  ;;
  4)
    clear ; del_user
  ;;
  5)
    clear ; check_user
  ;;
  6)
    clear ; user_list
  ;;  
  7)
    clear ; recert_xray
  ;;
  8)
   clear ; mport-xray
   ;;
  9)
   clear ; show_config
  ;;  
  0)
  sleep 0.5
  clear
  menu
  ;;
  *)
  echo -e "ERROR!! Please Enter an Correct Number"
  sleep 1
  clear
  mxray
  ;;
  esac
