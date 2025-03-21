<a href='https://codespaces.new/centralmind/sample_databases'><img src='https://github.com/codespaces/badge.svg' alt='Open in GitHub Codespaces' style='max-width: 100%;'></a>

# Sample Database API Generation Example using Github Codespaces

This example demonstrates how to:

- Launch the Discovery process
- Generate APIs
- Launch an API Server

The example uses a sample public PostgreSQL database hosted on Supabase.

## Prerequisites

- <a href="https://aistudio.google.com/apikey">Google Gemeni API Key</a> - API Free tier is available
- 🚀 <a href="https://codespaces.new/centralmind/sample_databases>">Launch Codespaces</a> with prepared enviroment

## Usage

### 1. Start the Discovery Process

Run the following commands to start the discovery process. Replace `YOUR_KEY` with your Gemini API key.
Google provides a free tier for API keys without requiring a credit card or a complicated registration process, <a href="https://aistudio.google.com/apikey">here</a>:

```bash
export GEMINI_API_KEY=YOUR_KEY
```

```bash
./gateway discover \
  --config connection.yaml \
  --ai-provider gemini \
  --prompt "Develop an API that enables a chatbot to retrieve information about data. Try to place yourself as analyst and think what kind of data you will require, based on that come up with useful API methods for that"
```

### 2. Launch the REST API Server

To start the REST API server and test its functionality, run:

```bash
./gateway start rest \
  --config gateway.yaml \
  --servers https://${CODESPACE_NAME}-9090.app.github.dev/
```

## Note

Make sure you have the necessary configuration files (`connection.yaml` and `gateway.yaml`) set up before running the commands.
