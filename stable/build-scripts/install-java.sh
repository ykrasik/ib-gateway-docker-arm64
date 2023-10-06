#!/bin/bash

ARCH=$(uname -m)
URL=""
ARCHIVE_NAME=""
JVM_DIR=""

if [ "$ARCH" == "x86_64" ]; then
    URL="https://mirrors.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz"
    ARCHIVE_NAME="jdk-8u202-linux-x64.tar.gz"
    JVM_DIR="jdk1.8.0_202"
elif [ "$ARCH" == "aarch64" ]; then
    URL="https://download.bell-sw.com/java/11.0.17+7/bellsoft-jre11.0.17+7-linux-aarch64-full.tar.gz"
    ARCHIVE_NAME="bellsoft-jre11.0.17+7-linux-aarch64-full.tar.gz"
    JVM_DIR="jre-11.0.17-full"
else
    echo "Unsupported architecture"
    exit 1
fi

if [ ! -f $ARCHIVE_NAME ]; then
    curl -L "$URL" --output $ARCHIVE_NAME
fi

tar -xzvf $ARCHIVE_NAME
rm $ARCHIVE_NAME

mv $JVM_DIR /opt/java
