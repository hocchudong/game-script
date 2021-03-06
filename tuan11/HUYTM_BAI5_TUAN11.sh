#!/bin/bash

ipu=`ip addr show eth0| grep /24 | awk '{print $2;}'|sed 's/\/.*$//'`
ipc=`ip addr show eth0| grep /24 | awk '{print $2;}'|sed 's/\/.*$//'`
export ipu=$ipu
export ipc=$ipc
# Bat dau cai dat
echo "###### KIEM TRA HE DIEU HANH ######"
sleep 3
os=`cat /etc/issue| awk 'FNR == 1 {print $1}'`
export os=$os
echo "###### HE DIEU HANH BAN SU DUNG LA $os ######"
sleep 5

if [ "$os" = "Ubuntu" ];then

installed=`dpkg -l | grep tomcat | awk 'FNR == 2 {print $2}'`
	#Kiem tra da cai dat chua
	if [ "$installed" = "tomcat7" ];then
			tput setaf 2
			echo "######## MAY BAN DA CAI TOMCAT ROI ########"
			echo "######## TRUY CAP VAO DIA CHI SAU ########"
			p1=`awk 'FNR == 72 {print $2}' /var/lib/tomcat7/conf/server.xml`
			echo "$ipu voi $p1"
			tput setaf 7
	
	else
			# Cai dat tren ubuntu
			echo "###### BAT DAU CAI DAT ######"
			sleep 3
		#1. Update he thong
			echo "######## UPDATE HE THONG ######"
			sleep 3
			apt-get update -y
			sleep 3

		#2. Cai dat JDK
			echo "######## CAI DAT JDK ########"
			sleep 3
			apt-get install openjdk-7-jdk -y
			echo "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> /etc/environment
			sleep 3
			echo "######## Kiem tra lai ########"
			sleep 3
			java -version
			sleep 5

		#3. Cai dat tomcat
			echo "######## BAT DAU CAI DAT TOM CAT ########"
			apt-get install tomcat7 -y
			sleep 3
			tput setaf 2
			echo -e "######## NHAP PORT CHO WEBSERVER ########"
			read port
			tput setaf 7
			export port=$port
			sed -i s/8080/$port/g /etc/tomcat7/server.xml

			echo "######## TAO TRANG INDEX ########"
			mv /var/lib/tomcat7/webapps/ROOT/index.html /var/lib/tomcat7/webapps/ROOT/index.html.bak 
cat > /var/lib/tomcat7/webapps/ROOT/index.html <<EOF
<h1> CAI DAT TOMCAT TREN UBUNTU THANH CONG </h1>
EOF
			service tomcat7 restart
			service tomcat7 restart

		#4. Hien thi ra man hinh
			tput setaf 2
			echo -e "###### CAI DAT TOMCAT TREN UBUNTU THANH CONG TRUY CAP VAO DIA CHI SAU #######"
			echo -e "$ipu:$port"
			tput setaf 7
	fi
	fi		#Ket thuc cai dat o Ubuntu


if [ "$os" = "CentOS" ];then
	#Kiem tra cai dat chua
	installedcent=`rpm -qa | grep tomcat | awk 'FNR == 1 {print $1 }' | sed 's/\-.*$//'`
		if [ "$installedcent" = "tomcat6" ];then
			tput setaf 2
			echo "######## MAY BAN DA CAI TOMCAT ROI ########"
			echo "######## TRUY CAP VAO DIA CHI SAU ########"
			p2=`awk 'FNR == 69 {print $2}' /etc/tomcat6/server.xml`
			echo "$ipu voi $p2"
			tput setaf 7

		else
			echo "######## BAT DAU CAI DAT ########"
			sleep 3
	#1. Cai dat JDK
			echo "######## CAI DAT JDK ########"
			sleep 3
			yum install java-1.7.0-openjdk.x86_64 -y
			sleep 3
			java -version

	#2. Cai dat tomcat va cac goi bo tro
			echo "######## CAI DAT TOMCAT ########"
			yum install tomcat6 tomcat6-webapps tomcat6-admin-webapps -y
			sleep 3

	#3. Cau hinh tomcat
			tput setaf 2
			echo -e "######## NHAP PORT CHO WEBSERVER ########"
			read portcentos
			export portcentos=$portcentos
			tput setaf 7
			sed -i s/8080/$portcentos/g /etc/tomcat6/server.xml
			service tomcat6 restart


	#4. Them rule trong iptables
			echo "######## THEM RULE CHO IPTABLES #########"
			sleep 3
			mv /etc/sysconfig/iptables /etc/sysconfig/iptables.bak 
cat > /etc/sysconfig/iptables <<EOF
# Generated by iptables-save v1.4.7 on Wed Mar 18 18:24:09 2015
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [97:14936]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport $portcentos -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
#-A INPUT -p tcp -m state --state NEW -m tcp --dport portcentos -j ACCEPT
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
			service iptables restart
			sleep 3

	#5. Hien thi ra man hinh
			tput setaf 2
			echo -e "###### CAI DAT TOMCAT TREN CENTOS THANH CONG TRUY CAP VAO DIA CHI SAU #######"
			echo -e "$ipc:$portcentos"
			tput setaf 7
		fi
		fi
	#Ket thuc cai dat tren centos
