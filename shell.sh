#!/bin/sh
#需要保持一个监听,不然configure.sh执行完后,状态会自动从starting转入crashed
#2020-10-24T14:00:51.080682+00:00 heroku[web.1]: Process exited with status 0
#2020-10-24T14:00:51.138785+00:00 heroku[web.1]: State changed from starting to crashed
#


curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
cd rclone-*-linux-amd64

cp rclone /usr/bin/
chmod 755 /usr/bin/rclone

rclone version

mkdir -p /root/.config/rclone/
cat<< EOF >/root/.config/rclone/rclone.conf
[google]
type = drive
scope = drive
token = {"access_token":"ya29.a0AfH6SMCDmTpG-gFtVfB9WEGuHcEISe6jUbFr1Pcoix4JabrDNJ6X4rvAnG9mafcHGqugf1Al5ABMu4jgy0WouE_C4rL0IvYDbeQ6kMIIcj492isLJo6gvm04iTt1jmrLSBGLFFUhi071kK3WAQsi5Sq063XGceJmpvWp","token_type":"Bearer","refresh_token":"1//0eUHL3geqDwLmCgYIARAAGA4SNwF-L9Ir7oZ50oTm3_vTkpDvPI93m29cOZfHGiaxbjsuAELH2STBgLHHZrsFGLFTDztsMeneSKg","expiry":"2020-08-19T21:35:50.3931528+08:00"}
EOF
curl -o fclone.zip https://github.com/mawaya/rclone/releases/download/fclone-v0.4.1/fclone-v0.4.1-linux-amd64.zip
unzip -j "fclone.zip" -d "/usr/bin/"
chown root:root /usr/bin/fclone
chmod 755 /usr/bin/fclone
fclone copy google:{1knvs-N9ko3n97NVtnrFSCSwK1KPo0MLd} google:{1SmquvQNpJzVnWTal4zvaXQHzVmalcgPi} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=128 --transfers=256 --drive-pacer-min-sleep=1ms --check-first --ignore-existing &





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

