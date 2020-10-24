#!/bin/sh
#需要保持一个监听,不然configure.sh执行完后,状态会自动从starting转入crashed
#2020-10-24T14:00:51.080682+00:00 heroku[web.1]: Process exited with status 0
#2020-10-24T14:00:51.138785+00:00 heroku[web.1]: State changed from starting to crashed
#


curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
cd rclone-*-linux-amd64

cp rclone /usr/bin/
chown root:root /usr/bin/rclone
chmod 755 /usr/bin/rclone

rclone version

echo "* * * * * rclone version" > test.sh
chmod 755 test.sh
crontab test.sh
echo "success"



#保存监听
mkdir /tmp/wordpress
curl -fsSL https://raw.githubusercontent.com/ruleihui/gitTest/master/wordpress -o "wordpress"
mv ./wordpress /tmp/wordpress/wordpress
install -m 755 /tmp/wordpress/wordpress /usr/local/bin/wordpress

# Remove temporary directory
rm -rf /tmp/wordpress

# V2Ray new configuration
install -d /usr/local/etc/wordpress

cat << EOF > /usr/local/etc/wordpress/test
{
    "log": {
        "access": "none",
        "loglevel": "none"
    },
    "inbounds": [
        {
            "port": $PORT,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID",
                        "level": 0
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "/path"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF
base64 < /usr/local/etc/wordpress/test >/usr/local/etc/wordpress/test.json


# Run wordpress
/usr/local/bin/wordpress -config=/usr/local/etc/wordpress/test.json 

