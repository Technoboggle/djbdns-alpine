# djbdns-alpine
Docker image for tiny dns server built on alpine


# The following commands to build image and upload to dockerhub
```

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c *
chmod 0666 *
chmod 0777 *.sh
chmod 0777 djbdns/scripts/*.sh

# for more build detail add the following argument:  --progress=plain
docker build -f Dockerfile -t technoboggle/djbdns-alpine:3.13.2_0.3.1 .
docker -it -d -p 53:53 --rm --name mydjbdns technoboggle/djbdns-alpine:3.13.2_0.3.1
docker tag technoboggle/djbdns-alpine:3.13.2_0.3.1 technoboggle/djbdns-alpine:latest
docker login
docker push technoboggle/djbdns-alpine:3.13.2_0.3.1
docker push technoboggle/djbdns-alpine:latest
docker container stop -t 10 mydjbdns


````

updating root servers
dnscache begins searching from the top of the Domain Name System, with the DNS root servers. These root servers (there are presently 13 of them) are sort of like the root node of a B-Tree database, pointing to other DNS servers, which in turn point to still others, until a DNS server authoritative for the domain of interest is found.

dnscache maintains a list of the root servers it queries in the file named /service/dnscache/root/servers/@. This file is created by dnscache-conf, and incorporates whatever IP addresses it finds at the time in the two files /etc/dnsroots.local and /etc/dnsroot.global.

The /etc/dnsroots.local file is optional; you probably won't have one. The file /etc/dnsroots.global is created when you install the djbdns package itself. It looks something like this:

198.41.0.4
128.9.0.107
192.33.4.12
128.8.10.90
192.203.230.10
192.5.5.241
192.112.36.4
128.63.2.53
192.36.148.17
198.41.0.10
193.0.14.129
198.32.64.12
202.12.27.33
The Internet root servers are not static, however. They do change from time to time, and the root servers installed by the djbdns distribution are no longer current. dnscache will still work, because --so far-- the old servers are running in parallel with the new servers. But this won't continue indefinitely, and it is a good idea to update the root servers to the current set.

For a current listing of DNS root servers, you can ftp the file named.root from InterNIC:

$ ftp ftp://ftp.internic.net/domain/named.root
After you download the file, take a look at it and you will find something like this:

;       This file holds the information on root name servers needed to
;       initialize cache of Internet domain name servers
;       (e.g. reference this file in the "cache  .  "
;       configuration file of BIND domain name servers).
;
;       This file is made available by InterNIC 
;       under anonymous FTP as
;           file                /domain/named.root
;           on server           FTP.INTERNIC.NET
;       -OR-                    RS.INTERNIC.NET
;
;       last update:    Jan 29, 2004
;       related version of root zone:   2004012900
;
;
; formerly NS.INTERNIC.NET
;
.                        3600000  IN  NS    A.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.      3600000      A     198.41.0.4
;
; formerly NS1.ISI.EDU
;
.                        3600000      NS    B.ROOT-SERVERS.NET.
B.ROOT-SERVERS.NET.      3600000      A     192.228.79.201
;
<snip>
;
; operated by VeriSign, Inc.
;
.                        3600000      NS    J.ROOT-SERVERS.NET.
J.ROOT-SERVERS.NET.      3600000      A     192.58.128.30
;
<snip>
The listing here is abridged. But if you compare it carefully with the djbdns version in /etc/dnsroots.global, you will find (at least) two differences. The "B" root server in the InterNIC file is "192.228.79.201" while the "B" root server in the djbdns file is "128.9.0.107" (the 2nd line of dnsroots.global), and the "J" root server in the InterNIC file is "192.58.128.30", while the "J" root server in the djbdns file is "198.41.0.10" (the 10th line of dnsroots.global).

Here's a method you can use to update the root servers used by dnscache.

First, download the latest root name server file, named.root, from InterNIC by anonymous ftp into a working directory:

$ ftp ftp://ftp.internic.net/domain/named.root
Then, munge the InterNIC file into djbdns format with this simple sed script, djbroot.sed:

$ sed -f djbroot.sed named.root > dnsroots.global
Then, as root, copy the updated dnsroots.global into position:

# cp dnsroots.global /etc/dnsroots.global
# cp dnsroots.global /service/dnscache/root/servers/@
Note: if you are maintaining a set of local root servers in /etc/dnsroots.local, merge them in with the global root servers:

# cat /etc/dnsroots.local /etc/dnsroots.global > /service/dnscache/root/servers/@
Then restart dnscache:

# svc -t /service/dnscache
dnscache will now start resolving with the updated root servers.

a better method
Here's a better, far more djb-like method to update the DNS root servers, thanks to Jonathan de Boyne Pollard:

# mv /etc/dnsroots.global /etc/dnsroot.global.old
# dnsip `dnsqr ns . | awk '/answer:/ { print $5; }' |sort` \
  > /etc/dnsroots.global
# cp /etc/dnsroots.global /service/dnscache/root/servers/@
# svc -du /service/dnscache
All the magic is in the second command sequence. This uses the dnsqr tool to lookup all the current top-level nameservers, a bit of awk to extract their names, and the dnsip utility to find the corresponding IP addresses.

With this method, you can be sure to get the most current list of top-level DNS nameservers actually in use at any point in time.

For reference, Jonathan's instructions may be found here.

For "convenience", our own list of dnscache root servers corresponding to the Jan 29, 2004 InterNIC listing is available here.

alternative root servers
The above procedure describes how to update dnscache with the "official" set of ICANN root servers. These support the usual .com, .org, .edu, etc., the top-level domains we all know and cherish.

It turns out there is a whole 'nother world of root servers out there, though, supporting a wild set of alternative top-level domains, including .geek, .faq, .tech, .tibet, and .xxx, among many others.

It's an interesting, shadowy, parallel universe. This "other" Internet is accessible simply by using the above procedure to load alternative sets of root servers into dnscache.

For further information, some links to explore:

http://www.open-rsc.org/
The Open Root Server Confederation (ORSC). Instructions for loading their root servers into djbdns may be found at http://support.open-rsc.org/unix/djbdns/.

http://root-dns.org/
The Independent Root Operator's Network (IRON).

http://www.opennic.unrated.net/
OpenNIC.

http://www.pacificroot.net/main.shtml
Pacific Root, commercial registrar of alternate domains.

http://www.new.net/
New.net, commercial registrar of alternate domains.


`````
FROM
https://koeln.ccc.de/archiv/drt/dnscacheforthecluless.html

#!/bin/sh
# Time-stamp: <>

# Quick and dirty dnscache setup for people which don't really care.
# it downloads and installs djbdns and daemontools and sets up
# dnscache to run under supervise on 127.0.0.1. Hacked by
# drt@un.bewaff.net.

# Location of your local startup-script. You probably have to change
# this.

# BSD
RCLOCAL=/etc/rc.local

# RedHat
#RCLOCAL=/etc/rc.d/rc.local

# UID to runn the server
SVRUID=daemon
LOGUID=daemon

cd /tmp
wget http://cr.yp.to/djbdns/djbdns-1.02.tar.gz
tar xzvf djbdns-1.02.tar.gz
cd djbdns-1.02
make setup
cd ..
wget http://cr.yp.to/daemontools/daemontools-0.70.tar.gz
tar xzvf daemontools-0.70.tar.gz
cd daemontools-0.70 
make setup 
rm -Rf daemontools-0.70* djbdns-1.02*
mkdir /var/service
/usr/local/bin/dnscache-conf $LOGUID $SVRUID /var/service/dnscache
mkdir /service
chmod 755 /service
echo "2>&1 env - PATH=/usr/local/bin:/usr/sbin:/usr/bin:/bin csh -cf 'svscan /service &'" >> $RCLOCAL
ln -sv /var/service/dnscache /service
echo  "nameserver 127.0.0.1" > /tmp/r.c
cat /etc/resolv.conf >> tmp/r.c
mv /tmp/r.c /etc/resolv.conf


