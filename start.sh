#!/bin/sh

# configs
AUUID=c564d497-405b-41a6-9a34-9122282c9cab
CADDYIndexPage=https://3.bp.blogspot.com/-JjjhBm6s_EY/WQhyM7QTrSI/AAAAAAAACmQ/3oEDL--UU1ou0ZxVJjVcW__vJQfCoi23ACLcB/s1600/Periodic%2BTable%2Bof%2BElements.jpg
mkdir -p /etc/caddy/ /usr/share/caddy
cat > /usr/share/caddy/robots.txt << EOF
User-agent: *
Disallow: /
EOF
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGXRAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/xray.json

for file in $(ls /usr/share/caddy/$AUUID); do
    [[ "$file" != "StoreFiles" ]] && echo \<a href=\""$file"\" download\>$file\<\/a\>\<br\> >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

chmod +x ./v2ray ./v2ctl

# start
tor & /usr/local/bin/v2ray -config /xray.json & /usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
