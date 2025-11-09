#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="$(gcloud config get-value project 2>/dev/null)"
TOPIC="ecommerce-events"
DATASET="ecommerce_raw"
TABLE="orders_stream"

if [[ -z "${PROJECT_ID}" || "${PROJECT_ID}" == "(unset)" ]]; then
  echo "Defina o projeto: gcloud config set project <id>"
  exit 1
fi

echo ">> Projeto: ${PROJECT_ID}"

# tópico
if ! gcloud pubsub topics list --format="value(name)" | grep -q "/topics/${TOPIC}"; then
  echo ">> Criando tópico ${TOPIC}"
  gcloud pubsub topics create "${TOPIC}"
fi

# dataset
if ! bq ls "${PROJECT_ID}:${DATASET}" >/dev/null 2>&1; then
  echo ">> Criando dataset ${DATASET}"
  bq --location=US mk --dataset "${PROJECT_ID}:${DATASET}"
fi

# tabela
if ! bq show "${PROJECT_ID}:${DATASET}.${TABLE}" >/dev/null 2>&1; then
  echo ">> Criando tabela ${TABLE} (particionada por dia)"
  bq mk --table --time_partitioning_type=DAY "${PROJECT_ID}:${DATASET}.${TABLE}" \
  event_id:STRING,event_type:STRING,event_time:TIMESTAMP,order_id:STRING,customer_id:STRING,currency:STRING,total_value:FLOAT,source:STRING,ingestion_ip:STRING,items:JSON
fi

# views
echo ">> (Re)criando views de BI"
bq query --quiet --use_legacy_sql=false < sql/create_views.sql

# seed
echo ">> Publicando 1000 eventos (eps=2)"
pushd publisher >/dev/null
export GOOGLE_CLOUD_PROJECT="${PROJECT_ID}" GCP_PROJECT="${PROJECT_ID}"
python app.py --eps 2 --max 1000
popd >/dev/null

# count
echo ">> Contagem de linhas:"
bq query --use_legacy_sql=false --format=table "
SELECT COUNT(*) AS total_rows
FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`"

# tail
echo ">> Últimas 10 linhas:"
bq query --use_legacy_sql=false --format=table "
SELECT event_time, order_id, total_value
FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`
ORDER BY event_time DESC
LIMIT 10"

echo "✅ Demo concluída!"
