#!/bin/bash
clear
red='\e[1;31m'
gr='\e[0;32m'
blue='\e[0;34m'
bb='\e[0;94m'
cy='\033[0;36m'
NC='\e[0m'
clear

pass=$(cat /etc/pass/accsess)
IZIN=$(curl https://raw.githubusercontent.com/zakiii20211/izinsc/main/ip | grep $pass | awk '{print $3}')
if [[ $today < $IZIN ]]; then
    echo -e ""
    clear
else
    echo -e ""
    clear
    echo -e "${red}ACCESS DENIED/EXPIRED...PM TELEGRAM OWNER${NC}"
    sleep 2
    exit 1
fi
clear

today=`date -d "0 days" +"%Y-%m-%d"`

IPVPS=$(curl -s icanhazip.com)
DOMAIN=$(cat /etc/xray/domain)
cekxray="$(openssl x509 -dates -noout < /usr/local/etc/xray/xray.crt)"                                      
expxray=$(echo "${cekxray}" | grep 'notAfter=' | cut -f2 -d=)
xcore="$(/usr/local/bin/xray -version | awk 'NR==1 {print $2}')"

usersc=$(cat /etc/pass/accsess)

usrvl="$gr$(grep -o -i "###" /usr/local/etc/xray/vless.txt | wc -l)$NC"
usrovpn="$gr$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)$NC"

expsc=$(curl https://raw.githubusercontent.com/zakiii20211/izinsc/main/ip | grep $pass | awk '{print $3}')


clear
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e  "  ${cy}IP VPS NUMBER                    : $IPVPS${NC}"
echo -e  "  ${cy}DOMAIN                           : $DOMAIN${NC}"
echo -e  "  ${cy}OS VERSION                       : `hostnamectl | grep "Operating System" | cut -d ' ' -f5-`"${NC}
echo -e  "  ${cy}KERNEL VERSION                   : `uname -r`${NC}"
echo -e  "  ${cy}XRAY CORE VERSION                : $xcore${NC}"
echo -e  "  ${cy}EXP DATE CERT XRAY               : $expxray${NC}"
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " "   "         " ${cy}TOTAL SSH : ${NC}" [$usrovpn]" ${cy}TOTAL XRAY : ${NC}" [$usrvl]"
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " \033[30;5;47m                         ⇱ VPN MENU ⇲                            \033[m"
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${bb}[ 01 ]${NC} MENU SSH                   ${bb}[ 02 ]${NC} MENU XRAY VLESS"
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " \033[30;5;47m                         ⇱ SYSTEM MENU ⇲                         \033[m"      
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC} "
echo -e  " ${bb}[ 03 ]${NC} ADD/CHANGE DOMAIN VPS      ${bb}[ 09 ]${NC} SPEEDTEST VPS"
echo -e  " ${bb}[ 04 ]${NC} CHANGE DNS SERVER          ${bb}[ 10 ]${NC} STREAM GEO LOCATION"
echo -e  " ${bb}[ 05 ]${NC} RESTART ALL SERVICE        ${bb}[ 11 ]${NC} ERVICE/PORT INFORMATION"
echo -e  " ${bb}[ 06 ]${NC} CHECK RAM USAGE            ${bb}[ 12 ]${NC} SERVICE STATUS"
echo -e  " ${bb}[ 07 ]${NC} REBOOT VPS                 ${bb}[ 13 ]${NC} SOCKS WRAP                " 
echo -e  " ${bb}[ 08 ]${NC} UPDATE                     ${bb}[ 14 ]${NC} autobackup"             
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}" 
echo -e  " ${bb}[  0 ]${NC}" "${cy}EXIT MENU${NC}  "
echo -e  " ${bb}═════════════════════════════════════════════════════════════════${NC}"
echo -e  " ${bb}══════════════════════════════════${NC}"
echo -e  " ${cy}SCRIPT VERSION :${NC} PREMIUM "
echo -e  " ${cy}USED BY        :${NC} $pass"
echo -e  " ${cy}EXPIRED ON     :${NC} $expsc"
echo -e  " ${bb}══════════════════════════════════${NC}"
echo -e  "  "
echo -e "\e[1;31m"
read -p  "     Please select an option :  " mnu
echo -e "\e[0m"
 case $mnu in
  1)
  clear ; mssh
  ;;
  2)
  clear ; mxray 
  ;;
  3)
  clear ; add-host
  ;;
  4)
  clear ; mdns
  ;;
  5)
  clear ; restart-service
  ;;
  6)
  clear ; ram
  ;;
  7)
  clear ; reboot
  ;;
  8)
  clear ; update
  ;;
  9)
  clear ; speedtest
  ;;
  10)
  clear ; nf
  ;;
  11)
  clear ; info
  ;;
  12)
  clear ; status
  ;;
  13)
  clear ; mwarp
  ;;
  14)
  clear ; autobackup
  ;;
  0)
  sleep 0.5
  clear
  exit
  ;;
  *)
  echo -e "ERROR!! Please Enter an Correct Number"
  sleep 1
  clear
  menu
  ;;
  esac
