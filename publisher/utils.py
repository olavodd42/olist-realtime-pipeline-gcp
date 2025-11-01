import uuid, random, string, socket
from datetime import datetime, timezone
from typing import Optional

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

def now_utc() -> str:
    """
    Função que obtém a data e hora atual.
    """
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

def host_ip() -> Optional[str]:
    """
    Função que obtém o ip do host.
    """
    try:
        return socket.gethostbyname(socket.gethostname())
    except Exception:
        return None
