#!/bin/sh
#需要保持一个监听,不然configure.sh执行完后,状态会自动从starting转入crashed
#2020-10-24T14:00:51.080682+00:00 heroku[web.1]: Process exited with status 0
#2020-10-24T14:00:51.138785+00:00 heroku[web.1]: State changed from starting to crashed
#heroku不允许脚本定义变量,只能去dashboard配置.所以通过设置临时文件并读取的方式设置变量
# shell里面怎么样把字符串转换为数字？
# 例如：a="024"
# 1，用${{a}}
# 2，用let达到(()) 运算效果。
# let num=0123;
# echo $num; 
# 83
# 3，双括号运算符:
# a=$((1+2));
# echo $a;
# 等同于：
# a=`expr 1 + 2`
# 而数字会默认做字符串处理
# 变量用单引号''变字符串
# i=1
# echo '$i';
# 输出：$1

curl -LJo rcloneTemp.zip https://github.com/rclone/rclone/releases/download/v1.53.2/rclone-v1.53.2-linux-amd64.zip
unzip rcloneTemp.zip
mv rclone*amd64 rcloneTemp

cd rcloneTemp

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
cp ./fclone*/fclone /usr/bin/fclone1
cp  ./fclone*/fclone /usr/bin/fclone2
chmod 755 /usr/bin/fclone1
chmod 755 /usr/bin/fclone2
mkdir accounts
#rclone copy eee:accounts.zip d:\Temp1\
rclone copy kkk:accounts.zip /rcloneTemp/accounts/
unzip -q -o -j "/rcloneTemp/accounts/accounts.zip" -d "./accounts/"

echo "------------accounts total"`ls /rcloneTemp/accounts/ | wc -l`

echo "------------accounts file get and unzip over" 

#任务1
#2017
cat << EOF > CopyTask1
#!/bin/sh

fclone1 copy lss:{1Hj7YSwWQnaIgY7ln_6AXt_PTbnjMAY7y} lss:{1Vsk3JBqVhr7hWTAQESAcKVSD7ZUNxM6q} --drive-server-side-across-configs --stats=2s --stats-one-line -vP --checkers=128 --transfers=256 --drive-pacer-min-sleep=1ms --check-first --ignore-existing 


EOF

chmod 755 CopyTask1
cp CopyTask1 /usr/bin/
./CopyTask1 &
sleep 1
echo `ps -ef | grep fclone1 |grep -v grep| awk '{print $1}'` > task1
echo ”*********”`cat task1`
chmod 755 task1
#任务2
#2019
cat << EOF > CopyTask2
#!/bin/sh
fclone2 copy lss:{1xgAq19msrgyclWey5y6z_bMq7SIatn9m} lss:{1dT0iiwdn4IGHw8pGidzIg_WTK260mwDI} --drive-server-side-across-configs --stats=2s --stats-one-line -vP --checkers=128 --transfers=256 --drive-pacer-min-sleep=1ms --check-first --ignore-existing 

EOF

chmod 755 CopyTask2
cp CopyTask2 /usr/bin/
./CopyTask2 &
sleep 1
echo `ps -ef | grep fclone2 | grep -v grep | awk '{print $1}'` > task2
echo ”*********”`cat task2`
chmod 755 task2
# #!/bin/sh 表示使用什么操作这个命令,如果waitkill使用#!/bin/bash 因为shell.sh的头是#!/bin/sh,会报找不到命令的错误
echo $((`date +%s`+86400)) > startDate
echo $((`date +%s`+60)) > intervalTime

#打印仍将保持时间
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
        echo "------------Keep active by curl http request------------"
        curl https://cron-to-copy.herokuapp.com/
        sleep 3
        @bbb@
        if [ @ccc@ -ge 2 ]
        then
            echo "------------Kill Old Task2 ------------"
            echo ”*********”\`ps -ef | grep fclone2 | grep -v grep\`
            pkill -f fclone2
            
            
            echo "------------Sleep 5 Wait Task2 Was Killed------------"
            sleep 5
            echo "------------Start New Task2------------"
            CopyTask2 &
            sleep 1
            echo ”*********”\`ps -ef | grep fclone2 | grep -v grep\`

        else
            echo "------------2019 was over ------------"
        fi
        if [ @ddd@ -ge 2 ]
        then
            echo "------------Kill Old Task1 ------------"
            echo ”*********”\`ps -ef | grep fclone1 | grep -v grep\`
            pkill -f fclone1
            
            echo "------------Sleep 5 Wait Task1 Was Killed------------"
            sleep 5
            echo "------------Start New Task1------------"
            CopyTask1 &
            sleep 1
            echo ”*********”\`ps -ef | grep fclone1 | grep -v grep\`
        else
            echo "------------2017 was over ------------"
        fi
        continue
    fi
    if [ $intNum -ge $((`cat startDate`)) ]
    then
        echo "------------Stop Dynos------------"
        if [ @ccc@ -ge 2 ]
        then
            pkill -f fclone2
        fi
        if [ @ddd@ -ge 2 ]
        then
            pkill -f fclone1
        fi
        break
    fi
    if [ @xxx@ -eq 1 ]
    then
        echo '*******************current tasks was done'
        echo \`ps -ef\`
        break
    fi
done
EOF
#设置间隔判断
sed -i 's|@bbb@|echo $(($((`date +%s`)) + 600)) > intervalTime|' waitkill

sed -i 's|@aaa@|$((`cat intervalTime`))|' waitkill

sed -i 's|@ccc@|`ps -ef \| grep -c  fclone2`|' waitkill

sed -i 's|@ddd@|`ps -ef \| grep -c  fclone1`|' waitkill

sed -i 's|@xxx@|`ps -ef \| grep -c  fclon `|' waitkill

#最后一个转义符没有生效
#sed -i 's|@ddd1@|echo `ps -ef \| grep fclone1 \| grep -v grep \| awk \'{print $1}\' ` > task1 | ' waitkill
#sed -i 's|@ddd2@|echo `ps -ef \| grep fclone2 \| grep -v grep \| awk \'{print $1}\' ` > task2 | ' waitkill

echo "*****************************"`ps -ef | grep  fclone1` 
echo "*****************************"`ps -ef | grep  fclone2` 
chmod 755 waitkill
cp waitkill /usr/bin/
waitkill &







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

