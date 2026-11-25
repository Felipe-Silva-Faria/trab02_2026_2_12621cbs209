import os
import re

URL_PADRAO = "http://127.0.0.1:8000/ativos"

_HOST_BARRA_PORTA = re.compile(r"^(https?://)([^/:]+)/(\d{2,5})(/.*)?$")


def normalizar_url_api(texto):
    """Aceita as formas que as pessoas digitam e devolve sempre .../ativos.

    "localhost:2209"                 -> "http://localhost:2209/ativos"
    "http://10.0.99.150:2209/"       -> "http://10.0.99.150:2209/ativos"
    "http://10.0.99.150:2209/docs"   -> "http://10.0.99.150:2209/ativos"
    "10.0.99.150/2209"               -> "http://10.0.99.150:2209/ativos"
    """
    url = (texto or "").strip()
    if not url:
        return URL_PADRAO
    if not re.match(r"^https?://", url, re.IGNORECASE):
        url = "http://" + url
    corrigida = _HOST_BARRA_PORTA.match(url)
    if corrigida:
        esquema, host, porta, resto = corrigida.groups()
        url = f"{esquema}{host}:{porta}{resto or ''}"
    url = url.rstrip("/")
    url = re.sub(r"/(docs|redoc|health)$", "", url)
    if not url.endswith("/ativos"):
        url += "/ativos"
    return url


URL_API = normalizar_url_api(os.getenv("CRUD_URL_API", ""))
ARQUIVO_TXT = "banco_ativos.txt"
COR_FUNDO = "#1a001f"
COR_PAINEL = "#2b0033"
COR_VIOLETA = "#6a0dad"
COR_VIOLETA_CLARO = "#8a2be2"
COR_TEXTO = "#ffffff"
