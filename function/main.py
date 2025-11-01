import base64, json, os
from google.cloud import bigquery

BQ_DATASET = os.getenv("BQ_DATASET", "ecommerce_raw")
BQ_TABLE   = os.getenv("BQ_TABLE", "orders_stream")

# Cria cliente BigQuery
bq = bigquery.Client()

def _parse_message(data_bytes: bytes) -> dict:
    """
    Analisa os dados da mensagem Pub/Sub recebida, decodifica de UTF-8,
    carrega como JSON e realiza uma normalização mínima para garantir
    que os tipos de dados correspondam ao esquema esperado do BigQuery.
    
    Args:
        data_bytes: Os dados brutos em bytes recebidos da mensagem Pub/Sub.
    """

    payload = json.loads(data_bytes.decode("utf-8"))
    # Normalização mínima: garantir tipos esperados pelo schema
    payload["event_time"] = payload.get("event_time")
    payload["total_value"] = float(payload.get("total_value", 0))
    payload["items"] = json.dumps(payload.get("items", []), ensure_ascii=False)
    return payload

def pubsub_to_bq(event, context):
    """
    Processa mensagens do Pub/Sub e as insere no BigQuery.

    Esta função é acionada por uma mensagem do Pub/Sub. Ela decodifica a mensagem,
    analisa seu conteúdo, normaliza os dados e, em seguida, insere a linha resultante
    em uma tabela do BigQuery.

    Args:
        event (dict): O payload do evento Pub/Sub. Contém os dados da mensagem.
        context (google.cloud.functions.Context): Metadados para este evento.
    """
    if "data" not in event:
        print("No data in event")
        return

    data = base64.b64decode(event["data"])
    row = _parse_message(data)

    table_id = f"{bq.project}.{BQ_DATASET}.{BQ_TABLE}"
    errors = bq.insert_rows_json(table_id, [row])
    if errors:
        print("BQ insert errors:", errors)
    else:
        print("Inserted:", row.get("event_id"))
