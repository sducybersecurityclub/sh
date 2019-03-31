# https://blog.csdn.net/flurry_rain/article/details/82706375
# ubuntu server 64位系统测试通过,请在root用户下运行
apt update -y #更新软件包
apt install -y wget gcc make #下载必要的软件
mkdir /home/temp/apache -p #下载apache2服务
cd /home/temp/apache
wget http://archive.apache.org/dist/httpd/httpd-2.2.34.tar.gz
tar xzvf httpd-2.2.34.tar.gz
mkdir /home/temp/openssl -p #安装openssl
cd /home/temp/openssl
wget http://www.openssl.org/source/openssl-1.0.1b.tar.gz
tar xzvf openssl-1.0.1b.tar.gz
apt remove -y openssl #移除原来的openssl
mkdir /usr/local/ssl -p
cd openssl-1.0.1b
./config --prefix=/usr/local/ssl  shared  -fPIC  no-gost
rm -f /usr/bin/pod2man
make
make install
rm /usr/lib/x86_64-linux-gnu/libssl.so -f 
rm /usr/lib/x86_64-linux-gnu/libcrypto.so -f
rm /lib/x86_64-linux-gnu/libssl.so -f 
rm /lib/x86_64-linux-gnu/libcrypto.so -f
cp /usr/local/ssl/lib/libssl.so /lib/x86_64-linux-gnu/
cp /usr/local/ssl/lib/libcrypto.so /lib/x86_64-linux-gnu/
cp /usr/local/ssl/lib/libssl.so /usr/lib/x86_64-linux-gnu/
cp /usr/local/ssl/lib/libcrypto.so /usr/lib/x86_64-linux-gnu/
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
echo "export OPENSSL=/usr/local/ssl/bin" >> /etc/profile
echo "export PATH=$OPENSSL:$PATH:$HOME/bin" >> /etc/profile
mv /usr/bin/ssl /usr/bin/openssl.old
mv /usr/include/ssl /usr/include/openssl.old
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
ln -sf /usr/local/ssl/lib/libcrypto.so.1.0.0 /lib/libcrypto.so.6
echo "/usr/local/ssl/lib" >>/etc/ld.so.conf
ldconfig -v
# 安装apache
mkdir /usr/local/httpd -p
mkdir /usr/local/apr -p
mkdir /usr/local/apr-util -p
cd /home/temp/apache/httpd-2.2.34/srclib/apr
./configure --prefix=/usr/local/apr
make
make install
cd /home/temp/apache/httpd-2.2.34/srclib/apr-util
./configure  --prefix=/usr/local/apr-util/ --with-apr=/usr/local/apr
make
make install
cd /home/temp/apache/httpd-2.2.34
./configure --prefix=/usr/local/httpd --enable-so --enable-rewrite --enable-ssl --with-ssl=/usr/local/ssl --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util
make
make install
sed -i 's/#Include conf/extra/httpd-ssl.conf/Include conf/extra/httpd-ssl.conf' /usr/local/httpd/conf/httpd.conf
cd /usr/local/httpd/conf
openssl genrsa -out server.key 2048 #生成密钥和证书
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
systemctl stop firewalld
cd /usr/local/httpd/bin
./apachectl start#!/bin/bash
