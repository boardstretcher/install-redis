# convert existing standalone to master

echo "New password for the redis master? "
read redis_master_password

sed -i 's/appendonly no/appendonly yes/g' /etc/redis.conf
sed -i 's/tcp-keepalive 300/tcp-keepalive 60/g' /etc/redis.conf
sed -i 's/bind 127.0.0.1/#bind 127.0.0.1/g' /etc/redis.conf
echo "requirepass $redis_master_password" >> /etc/redis.conf

systemctl stop redis
systemctl start redis
sleep 5; systemctl status redis
