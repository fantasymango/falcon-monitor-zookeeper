# falcon-monitor-zookeeper
## 使用shell脚本监控zookeeper
使用zookeeper的状态查看命令获取zookeeper的status
echo stat | nc 127.0.0.1 2181  查看zookeeper节点的信息
echo ruok | nc 127.0.0.1 2181  测试是否启用了该server，若回复imok则表示已经启动
echo wchs | nc 127.0.0.1 2181  列出服务器 watch 的详细信息

监控用法：
1、下载好脚本
2、根据实际情况修改脚本中的信息，如endpoint、zookeeper端口、push的url等
3、将脚本加入计划任务执行
