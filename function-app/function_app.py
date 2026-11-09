
import azure.functions as func
import logging
import os
import json
import urllib.request
import urllib.error

from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient

app = func.FunctionApp(
    http_auth_level=func.AuthLevel.FUNCTION
)


def get_foundry_api_key():
    """Retrieve the Foundry API key securely from Key Vault."""
    credential = ManagedIdentityCredential(
        client_id=os.environ["AZURE_CLIENT_ID"]
    )

    client = SecretClient(
        vault_url=os.environ["KEY_VAULT_URL"],
        credential=credential
    )

    secret = client.get_secret(
        os.environ["KEY_VAULT_SECRET_NAME"]
    )

    return secret.value


@app.route(route="keyvault-check", methods=["GET"])
def keyvault_check(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Starting Key Vault connectivity check.")

    try:
        secret_name = os.environ["KEY_VAULT_SECRET_NAME"]
        credential = ManagedIdentityCredential(
            client_id=os.environ["AZURE_CLIENT_ID"]
        )

        client = SecretClient(
            vault_url=os.environ["KEY_VAULT_URL"],
            credential=credential
        )

        secret = client.get_secret(secret_name)

        logging.info("Key Vault secret retrieved successfully.")

        return func.HttpResponse(
            body=json.dumps({
                "status": "success",
                "message": "Managed identity accessed Key Vault.",
                "secret_name": secret.name,
                "secret_version": secret.properties.version
            }),
            status_code=200,
            mimetype="application/json"
        )

    except Exception:
        logging.exception("Key Vault connectivity check failed.")

        return func.HttpResponse(
            body=json.dumps({
                "status": "failure",
                "message": "Key Vault access failed."
            }),
            status_code=500,
            mimetype="application/json"
        )


@app.route(route="chat", methods=["POST"])
def chat(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Received request for Foundry inference.")

    try:
        # Read the user's prompt
        request_data = req.get_json()
        prompt = request_data.get("message", "").strip()

        if not prompt:
            return func.HttpResponse(
                json.dumps({"error": "Please provide a message."}),
                status_code=400,
                mimetype="application/json"
            )

        # Retrieve the API key through managed identity
        api_key = get_foundry_api_key()

        # Prepare the Foundry chat completion request
        endpoint = os.environ["FOUNDRY_ENDPOINT"].rstrip("/")
        model = os.environ["FOUNDRY_MODEL"]

        url = f"{endpoint}/chat/completions"

        payload = {
            "model": model,
            "messages": [
                {
                    "role": "system",
                    "content": "You are a helpful enterprise AI assistant."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            "max_tokens": 300,
            "temperature": 0.2
        }

        data = json.dumps(payload).encode("utf-8")

        api_request = urllib.request.Request(
            url,
            data=data,
            headers={
                "Content-Type": "application/json",
                "api-key": api_key
            },
            method="POST"
        )

        # Call the deployed Phi-4 model
        with urllib.request.urlopen(
            api_request,
            timeout=60
        ) as response:
            result = json.loads(response.read().decode("utf-8"))

        answer = result["choices"][0]["message"]["content"]

        logging.info("Foundry inference completed successfully.")

        return func.HttpResponse(
            json.dumps({
                "status": "success",
                "model": model,
                "response": answer,
                "usage": result.get("usage", {})
            }),
            status_code=200,
            mimetype="application/json"
        )

    except urllib.error.HTTPError as error:
        logging.error(
            "Foundry returned HTTP status %s.",
            error.code
        )

        return func.HttpResponse(
            json.dumps({
                "status": "error",
                "message": "The Foundry inference request failed.",
                "upstream_status": error.code
            }),
            status_code=502,
            mimetype="application/json"
        )

    except Exception:
        logging.exception("Foundry inference failed.")

        return func.HttpResponse(
            json.dumps({
                "status": "error",
                "message": "Unable to complete the inference request."
            }),
            status_code=500,
            mimetype="application/json"
        )
