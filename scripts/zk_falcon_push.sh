#!/bin/bash
# 系统环境
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

# 全局变量
endpoint="sns_zk-ipaddr"
timenow=`date +%s`
valuetype="GAUGE"

# 获取zookeeper数据，端口号根据实际情况修改
echo stat | nc 127.0.0.1 2181 > /opt/scripts/tmp.stat
echo wchs | nc 127.0.0.1 2181 > /opt/scripts/tmp.wchs
echo ruok | nc 127.0.0.1 2181 > /opt/scripts/tmp.ruok

# stat 命令的结果处理
zookeeper_stat_received=`cat /opt/scripts/tmp.stat | grep "Received:" | awk '{print $2}'`
zookeeper_stat_sent=`cat /opt/scripts/tmp.stat | grep "Sent:" | awk '{print $2}'`
zookeeper_stat_clients=`cat /opt/scripts/tmp.stat | grep "sent" | wc -l`
zookeeper_stat_outstanding=`cat /opt/scripts/tmp.stat | grep "Outstanding:" | awk '{print $2}'`
zookeeper_stat_nodecount=`cat /opt/scripts/tmp.stat | grep "Node count:" | awk '{print $3}'`

# wchs 命令的结果处理
zookeeper_wchs_connections=`cat /opt/scripts/tmp.wchs | head -n1 | awk '{print $1}'`
zookeeper_wchs_watchingpaths=`cat /opt/scripts/tmp.wchs | head -n1 | awk '{print $4}'`
zookeeper_wchs_totalwatches=`cat /opt/scripts/tmp.wchs | grep 'Total watches' | awk -F\: '{print $2}'`

# ruok 命令的结果处理
zookeeper_ruok=`cat /opt/scripts/tmp.ruok | grep 'imok' | wc -l`

# 删除临时文件
rm -f /opt/scripts/tmp.stat /opt/scripts/tmp.wchs /opt/scripts/tmp.ruok

# 声明一个关联数组，将metric与value组成key-value对
declare -A zk_arr
zk_arr=(["zookeeper_stat_received"]="$zookeeper_stat_received" ["zookeeper_stat_sent"]="$zookeeper_stat_sent" ["zookeeper_stat_clients"]="$zookeeper_stat_clients" ["zookeeper_stat_outstanding"]="$zookeeper_stat_outstanding" ["zookeeper_stat_nodecount"]="$zookeeper_stat_nodecount" ["zookeeper_wchs_connections"]="$zookeeper_wchs_connections" ["zookeeper_wchs_watchingpaths"]="$zookeeper_wchs_watchingpaths" ["zookeeper_wchs_totalwatches"]="$zookeeper_wchs_totalwatches" ["zookeeper_ruok"]="$zookeeper_ruok")

for key in ${!zk_arr[@]}
do
	echo "$key ==> ${zk_arr[$key]}"
	curl -X POST -d "[{
    		\"metric\": \"$key\",
    		\"endpoint\": \"$endpoint\",
    		\"timestamp\": $timenow,
    		\"step\": 60,
    		\"value\": \"${zk_arr[$key]}\",
    		\"counterType\": \"$valuetype\",
    		\"tags\": \"name=zookeeper_info\"
		}]" http://127.0.0.1:1988/v1/push
done
