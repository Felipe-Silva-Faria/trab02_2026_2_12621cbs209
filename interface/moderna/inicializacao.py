import sys

from algoritmos.ordenacao import ALGORITMOS
from api.cliente_api import ClienteAPI
from config import ARQUIVO_TXT, URL_API
from dominio.excecoes import ErroCRUD
from interface.moderna import preferencias
from persistencia.repositorio import RepositorioJsonLines
from persistencia.usuarios import RepositorioUsuariosJSON
from servicos.autenticacao import ServicoAutenticacao
from servicos.eventos import CONEXAO_ALTERADA, BarramentoEventos
from servicos.painel import FonteLocal, PainelVulnerabilidades
from servicos.servico_ativos import ServicoAtivos


def montar(modo_local=False):
    eventos = BarramentoEventos()
    if modo_local:
        fonte = FonteLocal(ServicoAtivos(RepositorioJsonLines(ARQUIVO_TXT)))
        descricao = "local"
    else:
        fonte = ClienteAPI(url=URL_API, arquivo_local=ARQUIVO_TXT,
                           ao_mudar_conexao=lambda online: eventos.publicar(CONEXAO_ALTERADA, online=online))
        descricao = "api"
    algoritmo = preferencias.ler().get("algoritmo", "merge")
    painel = PainelVulnerabilidades(fonte, eventos, algoritmo=algoritmo if algoritmo in ALGORITMOS else "merge")
    autenticacao = ServicoAutenticacao(RepositorioUsuariosJSON())
    return painel, autenticacao, eventos, descricao


def iniciar(modo_local=False):
    from interface.moderna.app import Aplicacao
    try:
        painel, autenticacao, eventos, descricao = montar(modo_local)
    except ErroCRUD as erro:
        texto = f"{erro}\n\nAPI configurada: {URL_API}\nPara trabalhar sem a API: python main.py --local"
        print(texto, file=sys.stderr)
        try:
            import tkinter as tk
            from tkinter import messagebox
            raiz = tk.Tk()
            raiz.withdraw()
            messagebox.showerror("Nao foi possivel conectar a API", texto, parent=raiz)
            raiz.destroy()
        except Exception:  # noqa: BLE001 - sem tela grafica, a mensagem ja saiu no terminal
            pass
        raise SystemExit(1) from None
    Aplicacao(painel, autenticacao, eventos, descricao).mainloop()
