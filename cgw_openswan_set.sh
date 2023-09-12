#!/bin/bash
yum install -y openswan
cat <<EOF> /etc/sysctl.conf
  net.ipv4.ip_forward = 1
  net.ipv4.conf.default.rp_filter = 0
  net.ipv4.conf.default.accept_source_route = 0
  net.ipv4.conf.all.accept_redirects = 0
  net.ipv4.conf.all.send_redirects = 0
   EOF
sysctl -p /etc/sysctl.conf

printf "고객 게이트웨이 IP는> "
read leftid
printf "터널1의 IP는> "
read right
printf "로컬 서브넷은> "
read local 
printf "원격 서브넷은> "
read remote

cat <<EOF> /etc/ipsec.d/aws.conf
conn Tunnel1
	authby=secret
	auto=start
	left=%defaultroute
	leftid="$leftid"
	right="$right"
	type=tunnel
	ikelifetime=8h
	keylife=1h
	phase2alg=aes128-sha1;modp1024
	ike=aes128-sha1;modp1024	
	keyingtries=%forever
	keyexchange=ike
	leftsubnet="$local"
	rightsubnet="$remote"
	dpddelay=10
	dpdtimeout=30
	dpdaction=restart_by_peer
EOF

cat <<EOF> /etc/ipsec.d/aws.secrets
$leftid $right : PSK "password"
EOF