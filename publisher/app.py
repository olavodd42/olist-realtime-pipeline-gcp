import os, json, argparse
from pydantic import BaseModel, Field
from google.cloud import pubsub_v1
from fakestore import get_products, sample_items
from typing import List, Dict, Optional
from utils import new_id, now_utc, host_ip
import random
from datetime import datetime, timezone, timedelta

PROJECT: Optional[str] = os.getenv("GOOGLE_CLOUD_PROJECT") or os.getenv("GCP_PROJECT")
TOPIC: str             = os.getenv("PUBSUB_TOPIC", "ecommerce-events")

class OrderEvent(BaseModel):
    """
    Classe
    """
    event_id: str
    event_type: str = "order_created"
    event_time: str
    order_id: str
    customer_id: str
    currency: str = "BRL"
    total_value: float = Field(ge=0)
    source: str = "fakestoreapi"
    ingestion_ip: str | None = None
    items: list

def make_event(products) -> dict:
    items = sample_items(products, max_items=3)
    total = round(sum(i["price"] * i["qty"] for i in items), 2)
    ev = OrderEvent(
        event_id=new_id("EVT"),
        event_time=now_utc(),
        order_id=new_id("ORD"),
        customer_id=new_id("CUS"),
        total_value=total,
        ingestion_ip=host_ip(),
        items=items
    )
    return ev.model_dump()

def main():
    """
    Função principal.
    """
    ap = argparse.ArgumentParser()
    ap.add_argument("--max", type=int, default=100, help="Qtde de eventos")
    ap.add_argument("--eps", type=float, default=2.0, help="Eventos/segundo")
    args = ap.parse_args()

    # Obtém os dados do catálogo de produtos, cria o cliente e monta o
    # endereço para onde as mensagens serão enviadas
    products = get_products()
    pub = pubsub_v1.PublisherClient()
    topic_path = pub.topic_path(PROJECT, TOPIC)

    # Calcula tempo de intervalo entre cada evento
    import time
    interval = 1.0 / args.eps if args.eps > 0 else 0

    # Cria um evento de solicitaçàp para cada iteração, convertendo para formato JSON,
    # publica no Pub/Sub e espera a confirmação
    # Além disso faz uma pausa para controlar a taxa de eventos por segundo
    for _ in range(args.max):
        ev = make_event(products)
        data = json.dumps(ev, ensure_ascii=False).encode("utf-8")
        f = pub.publish(topic_path, data)
        _ = f.result()
        print("published:", ev["event_id"], "| order:", ev["order_id"], "| total:", ev["total_value"])
        if interval > 0:
            time.sleep(interval)

if __name__ == "__main__":
    main()
