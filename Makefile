PROJECT_ID := $(shell gcloud config get-value project 2>/dev/null)
PUBSUB_TOPIC := ecommerce-events
DATASET := ecommerce_raw
TABLE := orders_stream

.PHONY: demo views count tail seed fast-seed check help

help:
	@echo "Alvos:"
	@echo "  make check       -> valida pré-requisitos do projeto"
	@echo "  make views       -> cria/recria views de BI"
	@echo "  make seed        -> publica 1000 eventos (eps=2)"
	@echo "  make fast-seed   -> publica 300 eventos (eps=5)"
	@echo "  make count       -> mostra contagem de linhas na tabela"
	@echo "  make tail        -> mostra últimas 10 linhas (tempo/ordem/valor)"
	@echo "  make demo        -> check + views + seed + count + tail"

check:
	@test -n "$(PROJECT_ID)" || (echo ">> defina um projeto: gcloud config set project <id>"; exit 1)
	@gcloud pubsub topics list --format="value(name)" | grep -q "/topics/$(PUBSUB_TOPIC)" || \
	 (echo ">> criando tópico $(PUBSUB_TOPIC)"; gcloud pubsub topics create $(PUBSUB_TOPIC))
	@bq ls $(PROJECT_ID):$(DATASET) >/dev/null 2>&1 || \
	 (echo ">> criando dataset $(DATASET)"; bq --location=US mk --dataset $(PROJECT_ID):$(DATASET))
	@bq show $(PROJECT_ID):$(DATASET).$(TABLE) >/dev/null 2>&1 || \
	 (echo ">> criando tabela $(TABLE) particionada por dia"; \
	  bq mk --table --time_partitioning_type=DAY $(PROJECT_ID):$(DATASET).$(TABLE) \
	  event_id:STRING,event_type:STRING,event_time:TIMESTAMP,order_id:STRING,customer_id:STRING,currency:STRING,total_value:FLOAT,source:STRING,ingestion_ip:STRING,items:JSON)

# views:
# 	@bq query --quiet --use_legacy_sql=false < sql/create_views.sql
views:
	@PROJECT_ID=$(PROJECT_ID) envsubst < sql/create_views.sql | \
	bq query --quiet --use_legacy_sql=false

seed:
	@cd publisher && \
	export GOOGLE_CLOUD_PROJECT=$(PROJECT_ID) GCP_PROJECT=$(PROJECT_ID) EVENT_TZ=America/Sao_Paulo && \
	python app.py --eps 2 --max 1000

fast-seed:
	@cd publisher && \
	export GOOGLE_CLOUD_PROJECT=$(PROJECT_ID) GCP_PROJECT=$(PROJECT_ID) EVENT_TZ=America/Sao_Paulo && \
	python app.py --eps 5 --max 300

count:
	@bq query --use_legacy_sql=false --format=pretty "\
	SELECT COUNT(*) AS total_rows \
	FROM \`$(PROJECT_ID).$(DATASET).$(TABLE)\`"

tail:
	@bq query --use_legacy_sql=false --format=pretty "\
	SELECT event_time, order_id, total_value \
	FROM \`$(PROJECT_ID).$(DATASET).$(TABLE)\` \
	ORDER BY event_time DESC \
	LIMIT 10"

demo: check views seed count tail
