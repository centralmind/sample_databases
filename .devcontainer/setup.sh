#!/bin/bash
echo "Running startup commands.."

wget https://github.com/centralmind/gateway/releases/download/v0.1.1/gateway-linux-amd64.tar.gz
tar -xzf gateway-linux-amd64.tar.gz
mv gateway-linux-amd64 gateway
chmod +x gateway
