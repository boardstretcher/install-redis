# centos 7
# standalone redis 3.2.5 + systemd service

# disable selinux and update centos
cat << EOF > /etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
EOF

setenforce 0

yum -y update
yum -y install vim wget

# download and compile
wget http://download.redis.io/releases/redis-3.2.5.tar.gz
tar xf redis-3.2.5.tar.gz
cd redis-3.2.5/
make
make install

# add redis user
adduser redis

# create systemd service
cat << EOF > /etc/systemd/system/redis.service
[Unit]
Description=Redis persistent key-value database
After=network.target

[Service]
ExecStart=/usr/local/bin/redis-server /etc/redis.conf --daemonize no
ExecStop=/usr/local/bin/redis-shutdown
User=redis
Group=redis

[Install]
WantedBy=multi-user.target
EOF

# create redis configuration
cat << EOF > /etc/redis.conf
bind 127.0.0.1
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
EOF

# start and test redis
systemctl start redis
sleep 5
redis-benchmark -q -n 1000 -c 10 -P 5
