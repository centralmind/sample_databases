VAR1=$(gh secret list | grep VAR1 | awk '{print $2}')

if [[ -z "$VAR1" ]]; then
  echo "Error: VAR1 is not available. Check your secrets."
  exit 1
fi

./gateway discover --config connection.yaml --db-type postgres --ai-api-key "$VAR1" --prompt "Develop an API that enables a chatbot to retrieve information about data. Try to place yourself as analyst and think what kind of data you will require, based on that come up with useful API methods for that"

unset VAR1
history -c