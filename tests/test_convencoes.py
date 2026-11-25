import re
from pathlib import Path

import pytest

RAIZ = Path(__file__).resolve().parent.parent
MATRICULA = "12621cbs209"
IDENTIFICADOR = f"trab02_2026_2_{MATRICULA}"
PORTA_EXTERNA = 2000 + int(MATRICULA[-3:])
PORTA_INTERNA = 8000


def _ler(nome):
    caminho = RAIZ / nome
    if not caminho.exists():
        pytest.skip(f"{nome} indisponivel neste ambiente (ex.: dentro da imagem de testes)")
    return caminho.read_text(encoding="utf-8")


def test_identificador_segue_as_regras():
    assert re.fullmatch(r"[a-z0-9_]+", IDENTIFICADOR)
    assert PORTA_EXTERNA == 2209


def test_compose_usa_o_identificador_em_todos_os_recursos():
    compose = _ler("compose.yaml")
    assert re.search(rf"^name:\s*{IDENTIFICADOR}\s*$", compose, re.MULTILINE)
    assert f"container_name: {IDENTIFICADOR}" in compose
    for imagem in re.findall(r"^\s+image:\s*(\S+)", compose, re.MULTILINE):
        assert imagem.startswith(f"{IDENTIFICADOR}:")
    for nome in re.findall(r"^\s+name:\s*(\S+)", compose, re.MULTILINE):
        assert nome.startswith(IDENTIFICADOR)


def test_mapeamento_de_porta():
    compose = _ler("compose.yaml")
    assert f'"{PORTA_EXTERNA}:{PORTA_INTERNA}"' in compose
    assert len(re.findall(r'"\d+:\d+"', compose)) == 1


def test_estrutura_minima_do_repositorio():
    _ler("compose.yaml")
    for nome in ["Dockerfile", "compose.yaml", "requirements.txt", "README.md", ".env.example", "data/README.md"]:
        assert (RAIZ / nome).exists(), nome


def test_segredo_fora_do_git():
    assert re.search(r"^\.env$", _ler(".gitignore"), re.MULTILINE)
    assert re.search(r"^CRUD_API_KEY=\s*$", _ler(".env.example"), re.MULTILINE)
