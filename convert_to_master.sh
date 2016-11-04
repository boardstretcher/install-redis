# convert existing standalone to master

sed -i 's/appendonly no/appendonly yes/g' /etc/redis.conf
sed -i 's/tcp-keepalive 300/tcp-keepalive 60/g' /etc/redis.conf
sed -i 's/bind 127.0.0.1/#bind 127.0.0.1/g' /etc/redis.conf
echo "requirepass some_crazy_password" >> /etc/redis.conf
systemctl restart redis
