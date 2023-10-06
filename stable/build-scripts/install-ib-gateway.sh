#!/bin/bash

IB_GATEWAY_VERSION=$1
IB_GATEWAY_RELEASE_CHANNEL=${2:-latest}

if [ -z "$IB_GATEWAY_VERSION" ]; then
    echo "Error: Missing IB_GATEWAY_VERSION parameter. Usage: install-ib-gateway.sh <IB_GATEWAY_VERSION> [IB_GATEWAY_RELEASE_CHANNEL]"
    exit 1
fi

if [ ! -f "ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh" ]; then
    curl -L "https://github.com/UnusualAlpha/ib-gateway-docker/releases/download/ibgateway-${IB_GATEWAY_RELEASE_CHANNEL}%40${IB_GATEWAY_VERSION}/ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh" \
    --output "ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh"
fi

if [ ! -f "ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh.sha256" ]; then
    curl -L "https://github.com/UnusualAlpha/ib-gateway-docker/releases/download/ibgateway-${IB_GATEWAY_RELEASE_CHANNEL}%40${IB_GATEWAY_VERSION}/ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh.sha256" \
    --output "ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh.sha256"
fi

# Extract Java version
JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F'.' '{print $1}')

# If Java version is greater than 8, we need to replace the -Djava.ext.dirs param which was removed after java 8
# with --add-modules=ALL-MODULE-PATH to prevent module errors.
if [ "$JAVA_VERSION" -gt 8 ]; then
    sed -i 's/-Djava.ext.dirs="$app_java_home\/lib\/ext:$app_java_home\/jre\/lib\/ext"/--add-modules=ALL-MODULE-PATH/g' "ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh"
fi

chmod +x "ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh"
app_java_home=/opt/java ./"ibgateway-${IB_GATEWAY_VERSION}-standalone-linux-x64.sh" -q -dir "/root/Jts/ibgateway/${IB_GATEWAY_VERSION}"
