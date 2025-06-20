#!/bin/bash 
export LANG=en_US.UTF-8
red='\033[0;31m'
bblue='\033[0;34m'
plain='\033[0m'
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}
readp(){ read -p "$(yellow "$1")" $2;}
[[ $EUID -ne 0 ]] && yellow "请以root模式运行脚本" && exit
#[[ -e /etc/hosts ]] && grep -qE '^ *172.65.251.78 gitlab.com' /etc/hosts || echo -e '\n172.65.251.78 gitlab.com' >> /etc/hosts
if [[ -f /etc/redhat-release ]]; then
release="Centos"
elif cat /etc/issue | grep -q -E -i "alpine"; then
release="alpine"
elif cat /etc/issue | grep -q -E -i "debian"; then
release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
elif cat /proc/version | grep -q -E -i "debian"; then
release="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
else 
red "不支持当前的系统，请选择使用Ubuntu,Debian,Centos系统" && exit 
fi
vsid=$(grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1)
op=$(cat /etc/redhat-release 2>/dev/null || cat /etc/os-release 2>/dev/null | grep -i pretty_name | cut -d \" -f2)
if [[ $(echo "$op" | grep -i -E "arch") ]]; then
red "脚本不支持当前的 $op 系统，请选择使用Ubuntu,Debian,Centos系统。" && exit
fi

v4v6(){
v4=$(curl -s4m5 icanhazip.com -k)
v6=$(curl -s6m5 icanhazip.com -k)
}

if [ ! -f acyg_update ]; then
green "首次安装Acme-yg脚本必要的依赖……"
if [[ x"${release}" == x"alpine" ]]; then
apk add wget curl tar jq tzdata openssl expect git socat iproute2 virt-what
else
if [ -x "$(command -v apt-get)" ]; then
apt update -y
apt install socat -y
apt install cron -y
elif [ -x "$(command -v yum)" ]; then
yum update -y && yum install epel-release -y
yum install socat -y
elif [ -x "$(command -v dnf)" ]; then
dnf update -y
dnf install socat -y
fi
if [[ $release = Centos && ${vsid} =~ 8 ]]; then
cd /etc/yum.repos.d/ && mkdir backup && mv *repo backup/ 
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
sed -i -e "s|mirrors.cloud.aliyuncs.com|mirrors.aliyun.com|g " /etc/yum.repos.d/CentOS-*
sed -i -e "s|releasever|releasever-stream|g" /etc/yum.repos.d/CentOS-*
yum clean all && yum makecache
cd
fi
if [ -x "$(command -v yum)" ] || [ -x "$(command -v dnf)" ]; then
if ! command -v "cronie" &> /dev/null; then
if [ -x "$(command -v yum)" ]; then
yum install -y cronie
elif [ -x "$(command -v dnf)" ]; then
dnf install -y cronie
fi
fi
if ! command -v "dig" &> /dev/null; then
if [ -x "$(command -v yum)" ]; then
yum install -y bind-utils
elif [ -x "$(command -v dnf)" ]; then
dnf install -y bind-utils
fi
fi
fi

packages=("curl" "openssl" "lsof" "socat" "dig" "tar" "wget")
inspackages=("curl" "openssl" "lsof" "socat" "dnsutils" "tar" "wget")
for i in "${!packages[@]}"; do
package="${packages[$i]}"
inspackage="${inspackages[$i]}"
if ! command -v "$package" &> /dev/null; then
if [ -x "$(command -v apt-get)" ]; then
apt-get install -y "$inspackage"
elif [ -x "$(command -v yum)" ]; then
yum install -y "$inspackage"
elif [ -x "$(command -v dnf)" ]; then
dnf install -y "$inspackage"
fi
fi
done
fi
touch acyg_update
fi

if [[ -z $(curl -s4m5 icanhazip.com -k) ]]; then
yellow "检测到VPS为纯IPV6，添加dns64"
echo -e "nameserver 2a00:1098:2b::1\nnameserver 2a00:1098:2c::1\nnameserver 2a01:4f8:c2c:123f::1" > /etc/resolv.conf
sleep 2
fi

acme2(){
if [[ -n $(lsof -i :80|grep -v "PID") ]]; then
yellow "检测到80端口被占用，现执行80端口全释放"
sleep 2
lsof -i :80|grep -v "PID"|awk '{print "kill -9",$2}'|sh >/dev/null 2>&1
green "80端口全释放完毕！"
sleep 2
fi
}
acme3(){
readp "请输入注册所需的邮箱（回车跳过则自动生成虚拟gmail邮箱）：" Aemail
if [ -z $Aemail ]; then
auto=`date +%s%N |md5sum | cut -c 1-6`
Aemail=$auto@gmail.com
fi
yellow "当前注册的邮箱名称：$Aemail"
green "开始安装acme.sh申请证书脚本"
bash ~/.acme.sh/acme.sh --uninstall >/dev/null 2>&1
rm -rf ~/.acme.sh acme.sh
uncronac
wget -N https://github.com/Neilpang/acme.sh/archive/master.tar.gz >/dev/null 2>&1
tar -zxvf master.tar.gz >/dev/null 2>&1
cd acme.sh-master >/dev/null 2>&1
./acme.sh --install >/dev/null 2>&1
cd
curl https://get.acme.sh | sh -s email=$Aemail
if [[ -n $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
green "安装acme.sh证书申请程序成功"
bash ~/.acme.sh/acme.sh --upgrade --use-wget --auto-upgrade
else
red "安装acme.sh证书申请程序失败" && exit
fi
}

checktls(){
if [[ -f /root/ygkkkca/cert.crt && -f /root/ygkkkca/private.key ]] && [[ -s /root/ygkkkca/cert.crt && -s /root/ygkkkca/private.key ]]; then
cronac
green "域名证书申请成功或已存在！域名证书（cert.crt）和密钥（private.key）已保存到 /root/ygkkkca文件夹内" 
yellow "公钥文件crt路径如下，可直接复制"
green "/root/ygkkkca/cert.crt"
yellow "密钥文件key路径如下，可直接复制"
green "/root/ygkkkca/private.key"
ym=`bash ~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}'`
echo $ym > /root/ygkkkca/ca.log
if [[ -f '/etc/hysteria/config.json' ]]; then
blue "检测到Hysteria-1代理协议，如果你安装了甬哥的Hysteria脚本，请在Hysteria脚本执行申请/变更证书，此证书将自动应用"
fi
if [[ -f '/etc/caddy/Caddyfile' ]]; then
blue "检测到Naiveproxy代理协议，如果你安装了甬哥的Naiveproxy脚本，请在Naiveproxy脚本执行申请/变更证书，此证书将自动应用"
fi
if [[ -f '/etc/tuic/tuic.json' ]]; then
blue "检测到Tuic代理协议，如果你安装了甬哥的Tuic脚本，请在Tuic脚本执行申请/变更证书，此证书将自动应用"
fi
if [[ -f '/usr/bin/x-ui' ]]; then
blue "检测到x-ui（xray代理协议），如果你安装了甬哥的x-ui脚本，开启tls选项，此证书将自动应用"
fi
if [[ -f '/etc/s-box/sb.json' ]]; then
blue "检测到Sing-box内核代理，如果你安装了甬哥的Sing-box脚本，请在Sing-box脚本执行申请/变更证书，此证书将自动应用"
fi
else
bash ~/.acme.sh/acme.sh --uninstall >/dev/null 2>&1
rm -rf /root/ygkkkca
rm -rf ~/.acme.sh acme.sh
uncronac
red "遗憾，域名证书申请失败，建议如下："
yellow "一、更换下二级域名自定义名称再尝试执行重装脚本（重要）"
green "例：原二级域名 x.ygkkk.eu.org 或 x.ygkkk.cf ，在cloudflare中重命名其中的x名称"
echo
yellow "二：因为同个本地IP连续多次申请证书有时间限制，等一段时间再重装脚本" && exit
fi
}

installCA(){
bash ~/.acme.sh/acme.sh --install-cert -d ${ym} --key-file /root/ygkkkca/private.key --fullchain-file /root/ygkkkca/cert.crt --ecc
}

checkip(){
v4v6
if [[ -z $v4 ]]; then
vpsip=$v6
elif [[ -n $v4 && -n $v6 ]]; then
vpsip="$v6 或者 $v4"
else
vpsip=$v4
fi
domainIP=$(dig @8.8.8.8 +time=2 +short "$ym" 2>/dev/null)
if echo $domainIP | grep -q "network unreachable\|timed out" || [[ -z $domainIP ]]; then
domainIP=$(dig @2001:4860:4860::8888 +time=2 aaaa +short "$ym" 2>/dev/null)
fi
if echo $domainIP | grep -q "network unreachable\|timed out" || [[ -z $domainIP ]] ; then
red "未解析出IP，请检查域名是否输入有误" 
yellow "是否尝试手动输入强行匹配？"
yellow "1：是！输入域名解析的IP"
yellow "2：否！退出脚本"
readp "请选择：" menu
if [ "$menu" = "1" ] ; then
green "VPS本地的IP：$vpsip"
readp "请输入域名解析的IP，与VPS本地IP($vpsip)保持一致：" domainIP
else
exit
fi
elif [[ -n $(echo $domainIP | grep ":") ]]; then
green "当前域名解析到的IPV6地址：$domainIP"
else
green "当前域名解析到的IPV4地址：$domainIP"
fi
if [[ ! $domainIP =~ $v4 ]] && [[ ! $domainIP =~ $v6 ]]; then
yellow "当前VPS本地的IP：$vpsip"
red "当前域名解析的IP与当前VPS本地的IP不匹配！！！"
green "建议如下："
if [[ "$v6" == "2a09"* || "$v4" == "104.28"* ]]; then
yellow "WARP未能自动关闭，请手动关闭！或者使用支持自动关闭与开启的甬哥WARP脚本"
else
yellow "1、请确保CDN小黄云关闭状态(仅限DNS)，其他域名解析网站设置同理"
yellow "2、请检查域名解析网站设置的IP是否正确"
fi
exit 
else
green "IP匹配正确，申请证书开始…………"
fi
}

checkacmeca(){
nowca=`bash ~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}'`
if [[ $nowca == $ym ]]; then
red "经检测，输入的域名已有证书申请记录，不用重复申请"
red "证书申请记录如下："
bash ~/.acme.sh/acme.sh --list
yellow "如果一定要重新申请，请先执行删除证书选项" && exit
fi
}

ACMEstandaloneDNS(){
v4v6
readp "请输入解析完成的域名:" ym
green "已输入的域名:$ym" && sleep 1
checkacmeca
checkip
if [[ $domainIP = $v4 ]]; then
bash ~/.acme.sh/acme.sh  --issue -d ${ym} --standalone -k ec-256 --server letsencrypt --insecure
fi
if [[ $domainIP = $v6 ]]; then
bash ~/.acme.sh/acme.sh  --issue -d ${ym} --standalone -k ec-256 --server letsencrypt --listen-v6 --insecure
fi
installCA
checktls
}

ACMEDNS(){
readp "请输入解析完成的域名:" ym
green "已输入的域名:$ym" && sleep 1
checkacmeca
freenom=`echo $ym | awk -F '.' '{print $NF}'`
if [[ $freenom =~ tk|ga|gq|ml|cf ]]; then
red "经检测，你正在使用freenom免费域名解析，不支持当前DNS API模式，脚本退出" && exit 
fi
if [[ -n $(echo $ym | grep \*) ]]; then
green "经检测，当前为泛域名证书申请，" && sleep 2
else
green "经检测，当前为单域名证书申请，" && sleep 2
fi
checkacmeca
checkip
echo
ab="请选择托管域名解析服务商：\n1.Cloudflare\n2.腾讯云DNSPod\n3.阿里云Aliyun\n 请选择："
readp "$ab" cd
case "$cd" in 
1 )
readp "请复制Cloudflare的Global API Key：" GAK
export CF_Key="$GAK"
readp "请输入登录Cloudflare的注册邮箱地址：" CFemail
export CF_Email="$CFemail"
if [[ $domainIP = $v4 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${ym} -k ec-256 --server letsencrypt --insecure
fi
if [[ $domainIP = $v6 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${ym} -k ec-256 --server letsencrypt --listen-v6 --insecure
fi
;;
2 )
readp "请复制腾讯云DNSPod的DP_Id：" DPID
export DP_Id="$DPID"
readp "请复制腾讯云DNSPod的DP_Key：" DPKEY
export DP_Key="$DPKEY"
if [[ $domainIP = $v4 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_dp -d ${ym} -k ec-256 --server letsencrypt --insecure
fi
if [[ $domainIP = $v6 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_dp -d ${ym} -k ec-256 --server letsencrypt --listen-v6 --insecure
fi
;;
3 )
readp "请复制阿里云Aliyun的Ali_Key：" ALKEY
export Ali_Key="$ALKEY"
readp "请复制阿里云Aliyun的Ali_Secret：" ALSER
export Ali_Secret="$ALSER"
if [[ $domainIP = $v4 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_ali -d ${ym} -k ec-256 --server letsencrypt --insecure
fi
if [[ $domainIP = $v6 ]]; then
bash ~/.acme.sh/acme.sh --issue --dns dns_ali -d ${ym} -k ec-256 --server letsencrypt --listen-v6 --insecure
fi
esac
installCA
checktls
}

ACMEDNScheck(){
wgcfv6=$(curl -s6m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
ACMEDNS
else
systemctl stop wg-quick@wgcf >/dev/null 2>&1
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
ACMEDNS
systemctl start wg-quick@wgcf >/dev/null 2>&1
systemctl restart warp-go >/dev/null 2>&1
systemctl enable warp-go >/dev/null 2>&1
systemctl start warp-go >/dev/null 2>&1
fi
}

ACMEstandaloneDNScheck(){
wgcfv6=$(curl -s6m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
ACMEstandaloneDNS
else
systemctl stop wg-quick@wgcf >/dev/null 2>&1
kill -15 $(pgrep warp-go) >/dev/null 2>&1 && sleep 2
ACMEstandaloneDNS
systemctl start wg-quick@wgcf >/dev/null 2>&1
systemctl restart warp-go >/dev/null 2>&1
systemctl enable warp-go >/dev/null 2>&1
systemctl start warp-go >/dev/null 2>&1
fi
}

acme(){
mkdir -p /root/ygkkkca
ab="1.选择独立80端口模式申请证书（仅需域名，小白推荐），安装过程中将强制释放80端口\n2.选择DNS API模式申请证书（需域名、ID、Key），自动识别单域名与泛域名\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in 
1 ) acme2 && acme3 && ACMEstandaloneDNScheck;;
2 ) acme3 && ACMEDNScheck;;
0 ) start_menu;;
esac
}

Certificate(){
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh证书申请，无法执行" && exit 
green "Main_Domainc下显示的域名就是已申请成功的域名证书，Renew下显示对应域名证书的自动续期时间点"
bash ~/.acme.sh/acme.sh --list
#readp "请输入要撤销并删除的域名证书（复制Main_Domain下显示的域名，退出请按Ctrl+c）:" ym
#if [[ -n $(bash ~/.acme.sh/acme.sh --list | grep $ym) ]]; then
#bash ~/.acme.sh/acme.sh --revoke -d ${ym} --ecc
#bash ~/.acme.sh/acme.sh --remove -d ${ym} --ecc
#rm -rf /root/ygkkkca
#green "撤销并删除${ym}域名证书成功"
#else
#red "未找到你输入的${ym}域名证书，请自行核实！" && exit
#fi
}

acmeshow(){
if [[ -n $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
caacme1=`bash ~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}'`
if [[ -n $caacme1 && ! $caacme1 == "Main_Domain" ]] && [[ -f /root/ygkkkca/cert.crt && -f /root/ygkkkca/private.key && -s /root/ygkkkca/cert.crt && -s /root/ygkkkca/private.key ]]; then
caacme=$caacme1
else
caacme='无证书申请记录'
fi
else
caacme='未安装acme'
fi
}
cronac(){
uncronac
crontab -l > /tmp/crontab.tmp
echo "0 0 * * * root bash ~/.acme.sh/acme.sh --cron -f >/dev/null 2>&1" >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
}
uncronac(){
crontab -l > /tmp/crontab.tmp
sed -i '/--cron/d' /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp
}
acmerenew(){
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh证书申请，无法执行" && exit 
green "以下显示的域名就是已申请成功的域名证书"
bash ~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}'
echo
#ab="1.无脑一键续期所有证书（推荐）\n2.选择指定的域名证书续期\n0.返回上一层\n 请选择："
#readp "$ab" cd
#case "$cd" in 
#1 ) 
green "开始续期证书…………" && sleep 3
bash ~/.acme.sh/acme.sh --cron -f
checktls
#;;
#2 ) 
#readp "请输入要续期的域名证书（复制Main_Domain下显示的域名）:" ym
#if [[ -n $(bash ~/.acme.sh/acme.sh --list | grep $ym) ]]; then
#bash ~/.acme.sh/acme.sh --renew -d ${ym} --force --ecc
#checktls
#else
#red "未找到你输入的${ym}域名证书，请自行核实！" && exit
#fi
#;;
#0 ) start_menu;;
#esac
}
uninstall(){
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "未安装acme.sh证书申请，无法执行" && exit 
curl https://get.acme.sh | sh
bash ~/.acme.sh/acme.sh --uninstall
rm -rf /root/ygkkkca
rm -rf ~/.acme.sh acme.sh
sed -i '/acme.sh.env/d' ~/.bashrc 
source ~/.bashrc
uncronac
[[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && green "acme.sh卸载完毕" || red "acme.sh卸载失败"
}

clear
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"           
echo -e "${bblue} ░██     ░██      ░██ ██ ██         ░█${plain}█   ░██     ░██   ░██     ░█${red}█   ░██${plain}  "
echo -e "${bblue}  ░██   ░██      ░██    ░░██${plain}        ░██  ░██      ░██  ░██${red}      ░██  ░██${plain}   "
echo -e "${bblue}   ░██ ░██      ░██ ${plain}                ░██ ██        ░██ █${red}█        ░██ ██  ${plain}   "
echo -e "${bblue}     ░██        ░${plain}██    ░██ ██       ░██ ██        ░█${red}█ ██        ░██ ██  ${plain}  "
echo -e "${bblue}     ░██ ${plain}        ░██    ░░██        ░██ ░██       ░${red}██ ░██       ░██ ░██ ${plain}  "
echo -e "${bblue}     ░█${plain}█          ░██ ██ ██         ░██  ░░${red}██     ░██  ░░██     ░██  ░░██ ${plain}  "
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" 
white "甬哥Github项目  ：github.com/yonggekkk"
white "甬哥blogger博客 ：ygkkk.blogspot.com"
white "甬哥YouTube频道 ：www.youtube.com/@ygkkk"
yellow "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" 
green "Acme-yg脚本版本号 V2023.12.18"
yellow "提示："
yellow "一、脚本不支持多IP的VPS，SSH登录的IP与VPS共网IP必须一致"
yellow "二、80端口模式仅支持单域名证书申请，在80端口不被占用的情况下支持自动续期"
yellow "三、DNS API模式不支持freenom免费域名申请，支持单域名与泛域名证书申请，无条件自动续期"
yellow "四、泛域名申请前须设置一个名称为 * 字符的解析记录 (输入格式：*.一级/二级主域)"
yellow "公钥文件crt保存路径：/root/ygkkkca/cert.crt"
yellow "密钥文件key保存路径：/root/ygkkkca/private.key"
echo
red "========================================================================="
acmeshow
blue "当前已申请成功的证书（域名形式）："
yellow "$caacme"
echo
red "========================================================================="
green " 1. acme.sh申请letsencrypt ECC证书（支持80端口模式与DNS API模式） "
green " 2. 查询已申请成功的域名及自动续期时间点 "
green " 3. 手动一键证书续期 "
green " 4. 删除证书并卸载一键ACME证书申请脚本 "
green " 0. 退出 "
echo
readp "请输入数字:" NumberInput
case "$NumberInput" in     
1 ) acme;;
2 ) Certificate;;
3 ) acmerenew;;
4 ) uninstall;;
* ) exit      
esac
