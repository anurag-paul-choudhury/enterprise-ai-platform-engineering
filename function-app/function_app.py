
import azure.functions as func
import logging
import os
from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient
# Initialize Azure Monitor telemetry
app = func.FunctionApp(
    http_auth_level=func.AuthLevel.FUNCTION
)


@app.route(route="keyvault-check", methods=["GET"])
def keyvault_check(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Starting Key Vault connectivity check.")

    try:
        # Read configuration from Function App settings
        vault_url = os.environ["KEY_VAULT_URL"]
        secret_name = os.environ["KEY_VAULT_SECRET_NAME"]
        client_id = os.environ["AZURE_CLIENT_ID"]

        # Authenticate using the user-assigned managed identity
        credential = ManagedIdentityCredential(
            client_id=client_id
        )

        # Connect to Azure Key Vault
        client = SecretClient(
            vault_url=vault_url,
            credential=credential
        )

        # Retrieve the secret without exposing its value
        secret = client.get_secret(secret_name)

        logging.info("Key Vault secret retrieved successfully.")

        return func.HttpResponse(
            body=(
                '{"status":"success",'
                '"message":"Managed identity accessed Key Vault.",'
                f'"secret_name":"{secret.name}",'
                f'"secret_version":"{secret.properties.version}"'
                '}'
            ),
            status_code=200,
            mimetype="application/json"
        )

    except Exception:
        logging.exception("Key Vault connectivity check failed.")

        return func.HttpResponse(
            body='{"status":"failure","message":"Key Vault access failed."}',
            status_code=500,
            mimetype="application/json"
        )
