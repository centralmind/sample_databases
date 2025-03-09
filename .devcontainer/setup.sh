#!/bin/bash
echo "Running startup commands.."

wget https://github.com/centralmind/gateway/releases/latest/download/gateway-linux-amd64.tar.gz
tar -xzf gateway-linux-amd64.tar.gz
mv gateway-linux-amd64 gateway
chmod +x gateway
chmod +x .devcontainer/run.sh