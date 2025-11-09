import uuid, random, string, socket
from datetime import datetime, timezone
from typing import Optional
import os
from zoneinfo import ZoneInfo


def new_id(prefix: str, n: int=6) -> str:
    """
    Função que cria um novo id aleatório a partir de um prefixo e do número
    de dígitos aleatórios desejado.
    Parâmetros:
        * prefix: str -> string que será utilizada como parte inicial do ID
        * n: int -> número inteiro que determina comprimento da parte aleatória
            do id. Por padrão, é 6.
    Retorna:
        * novo id.
    """
    return f"{prefix}-" + "".join(random.choices(string.digits, k=n))

def now_utc():
    """
    Retorna timestamp ISO 8601. Se EVENT_TZ estiver definido,
    usa esse fuso; caso contrário usa UTC.
    """
    tz = os.getenv("EVENT_TZ", "UTC")
    return datetime.now(ZoneInfo(tz)).isoformat(timespec="seconds")

def host_ip() -> Optional[str]:
    """
    Função que obtém o ip do host.
    """
    try:
        return socket.gethostbyname(socket.gethostname())
    except Exception:
        return None
