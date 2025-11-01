import requests, random
from typing import List, Dict

URL = "https://fakestoreapi.com/products"

def get_products() -> List[Dict]:
    """
    A função faz uma requisição do tipo GET para a página Fake Store API,
    verifica se há erros na requisição e retorna o JSON da resposta da API.
    """
    r = requests.get(URL, timeout=20)
    r.raise_for_status()
    return r.json()

def sample_items(products: List[Dict], max_items: int=3) -> List[Dict]:
    """
    Função que extrai uma amostra de produtos do catálogo.
    Parâmetros:
        * products: List[Dict] -> lista de produtos.
        * max_items: int -> número de items a serem amostrados do
        catálogo. Por padrão, é 3.
    Retorna:
        * items: List[Dict] -> lista de items amostrados.
    """
    k = random.randint(1, max_items)
    picks = random.sample(products, k)
    items = []
    for p in picks:
        qty = random.randint(1, 2)
        items.append({
            "product_id": f"PROD-{p['id']}",
            "category": p.get("category"),
            "title": p.get("title"),
            "price": float(p.get("price", 0.0)),
            "qty": qty
        })
    return items
