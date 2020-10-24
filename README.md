```
# $$是当前脚本的pid
# $! 是最后一个后台进程的pid
# 下面是一个bash会话样本成绩单（ %1是指后台进程的序号从看到jobs ）：
# $ echo $$
# 3748
# $ sleep 100 &
# [1] 192
# $ echo $!
# 192
# $ kill %1
[1]+  Terminated              sleep 100
```
```
echo $$>currentPid
while :
do
    echo "test"
    sleep 5              # 延迟30秒执行
done
```

./whileTest &

kill $(cat currentPid)

# wordpress

## 概述

用于在 Heroku 上部署 wordpress。



## 镜像

本镜像不会因为大量占用资源而被封号。

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/ruleihui/herokuTest)

