#!/bin/bash
echo "Running startup commands..."


wget https://github.com/centralmind/gateway/releases/latest/download/gateway-linux-amd64.tar.gz
tar -xzf gateway-linux-amd64.tar.gz
mv gateway-linux-amd64 gateway
chmod +x gateway


OPENAI_KEY=$(gh secret list | grep OPENAI_KEY | awk '{print $2}')

if [[ -z "$OPENAI_KEY" ]]; then
  echo "Error: OPENAI_KEY is not available."
  exit 1
fi

./gateway discover --config connection.yaml --db-type postgres --ai-api-key "$OPENAI_KEY" --prompt "Develop an API that enables a chatbot to retrieve information about data. Try to place yourself as analyst and think what kind of data you will require, based on that come up with useful API methods for that"
