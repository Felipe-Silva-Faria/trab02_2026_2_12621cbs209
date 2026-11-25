from pathlib import Path
from unittest.mock import MagicMock

import pytest

from api.cliente_api import ChaveRecusada, ClienteAPI
from config import URL_PADRAO, normalizar_url_api
from dominio.excecoes import ErroCRUD

RAIZ = Path(__file__).resolve().parent.parent


@pytest.mark.parametrize(("digitado", "esperado"), [
    ("", URL_PADRAO),
    ("http://127.0.0.1:8000/ativos", "http://127.0.0.1:8000/ativos"),
    ("localhost:2209", "http://localhost:2209/ativos"),
    ("http://localhost:2209/", "http://localhost:2209/ativos"),
    ("http://10.0.99.150:2209/docs", "http://10.0.99.150:2209/ativos"),
    ("10.0.99.150/2209", "http://10.0.99.150:2209/ativos"),          # erro real da S5
    ("  http://10.0.99.150:2209/ativos/  ", "http://10.0.99.150:2209/ativos"),
])
def test_url_da_interface_e_normalizada(digitado, esperado):
    assert normalizar_url_api(digitado) == esperado


def _resposta(status, corpo):
    r = MagicMock()
    r.status_code = status
    r.json.return_value = corpo
    return r


def _cliente(tmp_path, chave=""):
    sessao = MagicMock()
    sessao.headers = {}
    return ClienteAPI(url="http://api:2209", sessao=sessao, arquivo_local=tmp_path / "l.txt",
                      tentativas=1, chave_api=chave), sessao


def test_chave_vai_no_cabecalho_da_sessao_sem_espacos(tmp_path):
    cliente, sessao = _cliente(tmp_path, " segredo\r\n")
    assert sessao.headers["X-API-Key"] == "segredo"
    assert cliente.url == "http://api:2209/ativos"


@pytest.mark.parametrize("status", [401, 403])
def test_chave_recusada_tem_mensagem_clara_e_nao_vira_offline(tmp_path, status):
    cliente, sessao = _cliente(tmp_path, "errada")
    sessao.request.return_value = _resposta(status, {"detail": "nao autorizado"})
    with pytest.raises(ChaveRecusada, match="CRUD_API_KEY"):
        cliente.listar()
    assert cliente.online is True and cliente.pendentes.esta_vazia()


def test_resposta_que_nao_e_lista_explica_a_url(tmp_path):
    cliente, sessao = _cliente(tmp_path)
    sessao.request.return_value = _resposta(200, {"status": "ok"})
    with pytest.raises(ErroCRUD, match="CRUD_URL_API"):
        cliente.listar()


def _ler(nome):
    caminho = RAIZ / nome
    if not caminho.exists():
        pytest.skip(f"{nome} indisponivel neste ambiente")
    return caminho.read_text(encoding="utf-8")


def test_portas_e_caminhos_consistentes():
    compose, dockerfile = _ler("compose.yaml"), _ler("Dockerfile")
    assert '"2209:8000"' in compose                                  # externa 2000+209 -> interna
    assert "--port\", \"8000\"" in dockerfile                        # Uvicorn escuta a interna
    assert "127.0.0.1:8000/health" in dockerfile                     # HEALTHCHECK dentro do container
    assert "data:/app/data" in compose                               # volume montado em /app/data...
    assert "/app/dados" not in dockerfile                            # ...e o banco nao fica fora dele
    assert "/app/data/banco_api.db" in dockerfile
