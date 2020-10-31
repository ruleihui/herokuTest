#!/bin/sh
#需要保持一个监听,不然configure.sh执行完后,状态会自动从starting转入crashed
#2020-10-24T14:00:51.080682+00:00 heroku[web.1]: Process exited with status 0
#2020-10-24T14:00:51.138785+00:00 heroku[web.1]: State changed from starting to crashed
#heroku不允许脚本定义变量,只能去dashboard配置.所以通过设置临时文件并读取的方式设置变量


#curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
curl -LJO https://github.com/rclone/rclone/releases/download/v1.53.2/rclone-v1.53.2-linux-amd64.zip
unzip rclone-v1.53.2-linux-amd64.zip
cd rclone-*-linux-amd64

cp rclone /usr/bin/
chmod 755 /usr/bin/rclone

rclone version

mkdir -p /.config/rclone/
cat<< EOF >/.config/rclone/rclone.conf
$rcloneConfig
EOF
curl -LJO  https://github.com/mawaya/rclone/releases/download/fclone-v0.4.1/fclone-v0.4.1-linux-amd64.zip
unzip fclone-v0.4.1-linux-amd64.zip 
cp ./fclone*/fclone /usr/bin/
chmod 755 /usr/bin/fclone


#fclone copy google:{1knvs-N9ko3n97NVtnrFSCSwK1KPo0MLd} google:{1SmquvQNpJzVnWTal4zvaXQHzVmalcgPi} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=128 --transfers=256 --drive-pacer-min-sleep=1ms --check-first --ignore-existing &
fclone copy rulei:{1hPFOFJRIagC0tli9UzAv7vIJ0iDue2d9} rulei:{1nVeDpKZ7KPlchmAS6QUrxuSD4ZmMqrra} --drive-server-side-across-configs --stats=1s --stats-one-line -vP --checkers=128 --transfers=256 --drive-pacer-min-sleep=1ms --check-first --ignore-existing &

echo $!>currentPid


echo `cat currentPid`
# #!/bin/sh 表示使用什么操作这个命令,如果waitkill使用#!/bin/bash 因为shell.sh的头是#!/bin/sh,会报找不到命令的错误
echo $((`date +%s`+14400))> startDate
echo $((`date +%s`+600)) > intervalTime
cat << EOF > currentTime
#!/bin/sh

echo "remain:"\`expr \$2 - \$1 \`"second"

EOF
chmod 755 currentTime
cp currentTime /usr/bin/

cat << EOF > waitkill
#!/bin/sh
while :
do
    echo $$ > waitKillPid
    currentTime $intNum `cat startDate`
    sleep 2              # per sleep 60 second to do
    if [ $intNum -ge @aaa@ ]
    then
        echo "------------Keep active by curl http request------------------"
        curl https://testhreroks.herokuapp.com/
        @bbb@
        continue
    fi
    if [ $intNum -ge $((`cat startDate`)) ]
    then
        echo "------------Stop Fclone------------------"
        kill `cat currentPid`
        break
    fi
done
EOF

sed -i 's|@bbb@|echo $(($((`date +%s`)) + 600)) > intervalTime|' waitkill

sed -i 's|@aaa@|$((`cat intervalTime`))|' waitkill

chmod 755 waitkill
cp waitkill /usr/bin/
waitkill &

#if [ $Stop ]
#then 
#    echo "------------Stop by configVars------------------"
#    kill `cat currentPid`
#    echo "------------Stop waitkill by configVars------------------"
#   kill `cat waitKillPid`
#fi




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

