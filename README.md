# v5.1 - correcoes de conexao da interface, chave e URLs

| Arquivo | O que mudou |
|---|---|
| config.py | URL_API lida de CRUD_URL_API e normalizada (aceita sem /ativos, com / no fim, /docs e o erro "10.0.99.150/2209") |
| api/cliente_api.py | chave de CRUD_API_KEY no cabecalho da sessao (interfaces moderna e classica); 401/403 -> ChaveRecusada com mensagem clara; resposta que nao e lista -> erro explicando a URL; chave com .strip() |
| interface/moderna/inicializacao.py | cliente monta URL e chave num lugar so; erro de conexao vira mensagem (janela + terminal) em vez de traceback |
| api/app_rest.py | CRUD_API_KEY com .strip() (\r do Windows no .env nao bloqueia mais) e aviso quando vazia |
| registrar_ativos_exemplo.ps1 | -Url normalizado; sem -Url usa $env:CRUD_URL_API |
| docs/EVIDENCIAS_S5.md | SERVIDOR -> 10.0.99.150 |
| tests/test_conexao_interface.py | novo: URLs, chave no cliente, 401, portas 2209:8000 e caminho /app/data |

## Enderecos corretos

| Onde a API roda | CRUD_URL_API (interface) | -Url (script) |
|---|---|---|
| Uvicorn no PC (notebook) | http://127.0.0.1:8000/ativos (padrao) | http://127.0.0.1:8000 (padrao) |
| Docker no PC do laboratorio | http://localhost:2209/ativos | http://localhost:2209 |
| Servidor da turma (so rede UFU) | http://10.0.99.150:2209/ativos | http://10.0.99.150:2209 |
