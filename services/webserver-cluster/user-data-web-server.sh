#!/bin/bash
echo "Hello World!" > index.html
wget https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64
mv busybox-x86_64 busybox
chmod +x busybox
sudo mv busybox /usr/local/bin/
nohup busybox httpd -f -p 8080