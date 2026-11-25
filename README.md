# trab02_2026_2_12621cbs209 — CRUD de Ativos de TI

API REST (FastAPI) para gestão de ativos de TI, vulnerabilidades (CVSS 3.1) e risco residual.
Trabalho 02 — Cibersegurança — UFU — 2026/2 — Felipe Silva Faria (matrícula 12621CBS209).

## Identificação dos recursos (convenção S5)

Identificador: `trab02_2026_2_MATRICULA` → **`trab02_2026_2_12621cbs209`** (minúsculas, sem espaços, acentos, pontos ou traços).

| Recurso | Nome |
|---|---|
| Diretório / repositório Git | `trab02_2026_2_12621cbs209` |
| Projeto Compose | `trab02_2026_2_12621cbs209` |
| Container | `trab02_2026_2_12621cbs209` |
| Imagem | `trab02_2026_2_12621cbs209:5.0` (testes: `trab02_2026_2_12621cbs209:testes`) |
| Volumes | `trab02_2026_2_12621cbs209_data`, `trab02_2026_2_12621cbs209_logs` |
| Rede | `trab02_2026_2_12621cbs209_net` |
| Porta | `2209:8000` → externa = 2000 + 209 = **2209**; interna = **8000** (Uvicorn) |

## Estrutura

```
Dockerfile               imagem multi-stage (producao / testes)
compose.yaml             servico, porta, volumes, rede, limites e seguranca
.env.example             modelo das variaveis secretas (copiar para .env)
requirements.txt         dependencias completas (interface + API)
requirements-docker.txt  dependencias minimas da imagem
data/                    backups do volume de dados (conteudo fora do Git)
api/ dominio/ algoritmos/ estruturas/ persistencia/ servicos/ utilitarios/   codigo-fonte da API
interface/ main.py       interface grafica Tkinter (roda no computador do usuario, fora do Docker)
tests/                   testes automatizados (pytest), incluindo tests/test_convencoes.py
scripts/                 monitorar_24h.sh (evidencias) e backup_dados.sh
docs/EVIDENCIAS_S5.md    roteiro e registro das evidencias da S5
deploy/                  implantacao alternativa sem Docker (systemd)
```

## Pré-requisitos

Docker Engine com Docker Compose v2 (`docker compose version`) e Git.

## Construção e execução

### Linux (servidor)

```bash
git clone https://github.com/Felipe-Silva-Faria/trab02_2026_2_12621cbs209.git
cd trab02_2026_2_12621cbs209
cp .env.example .env
python3 -c "import secrets; print(secrets.token_urlsafe(32))"   # cole o valor em CRUD_API_KEY no .env
chmod 600 .env
docker compose config --quiet && echo "compose valido"
docker compose up -d --build
docker compose ps            # STATUS deve indicar (healthy)
curl http://localhost:2209/health
```

### Windows (PowerShell)

```powershell
Copy-Item .env.example .env
python -c "import secrets; print(secrets.token_urlsafe(32))"   # cole em CRUD_API_KEY no .env
notepad .env
docker compose up -d --build
docker compose ps
curl.exe http://localhost:2209/health
```

Documentação interativa: `http://10.0.99.150:2209/docs` → botão **Authorize** → informe a chave do `.env`.
Todas as rotas da API exigem o cabeçalho `X-API-Key`; ficam liberadas apenas `/health`, `/docs`, `/redoc` e `/openapi.json`.
Sem `CRUD_API_KEY` definida, o Compose se recusa a subir o serviço.

## Persistência

O banco SQLite fica em `/app/data/banco_api.db`, dentro do volume `trab02_2026_2_12621cbs209_data`.

- `docker compose down` remove o container e **preserva** os dados.
- `docker compose down -v` remove também os volumes (**apaga** os dados).
- Backup: `bash scripts/backup_dados.sh` → gera `data/backup_AAAAMMDD_HHMMSS.tar.gz`.

## Testes

```bash
python -m pytest -q tests/test_convencoes.py        # convencoes S5 (no host)
docker compose --profile testes run --rm testes        # suite completa no container
docker compose --profile ferramentas run --rm benchmark
```

## Operação

```bash
docker compose logs -f api          # logs (rotacao: 3 x 10 MB)
docker compose restart api          # reiniciar
git pull origin main && docker compose up -d --build   # atualizar
docker compose down                 # parar (mantem dados)
```

### Regras para o servidor compartilhado

- Execute comandos **somente** dentro da pasta do projeto ou filtrando pelo identificador
  (`docker ps --filter name=trab02_2026_2_12621cbs209`).
- **Não** use `docker system prune`, `docker volume prune`, `docker image prune -a`, `docker rm $(docker ps -aq)`
  nem `docker compose down` em pastas de outros alunos.
- Antes de subir, confirme que a porta 2209 está livre: `ss -ltn | grep ':2209 '`.

## Segurança

- Container executa como usuário sem privilégios (`app`).
- Sistema de arquivos somente leitura; escrita apenas em `/app/data`, `/app/logs` e `/tmp`.
- Todas as capabilities removidas e `no-new-privileges` ativo.
- Limites de 256 MB de memória, 0,5 CPU e 100 processos; logs do Docker com rotação.
- Rede própria (`trab02_2026_2_12621cbs209_net`), isolada dos projetos de outros alunos.
- Chave de API obrigatória, comparada em tempo constante (`hmac.compare_digest`); falhas registradas em log.
- `.env`, bancos, backups e arquivos de usuários fora do Git e da imagem.

## Funcionamento contínuo (24 h)

`restart: unless-stopped` e o `HEALTHCHECK` da imagem mantêm e monitoram o serviço.

```bash
AMOSTRAS=1 bash scripts/monitorar_24h.sh                       # foto inicial (T0)
nohup bash scripts/monitorar_24h.sh > /dev/null 2>&1 &         # 49 amostras, 1 a cada 30 min
docker inspect -f 'Inicio={{.State.StartedAt}} Reinicios={{.RestartCount}} Saude={{.State.Health.Status}}' trab02_2026_2_12621cbs209
```

Os registros ficam em `evidencias/`. Roteiro completo em `docs/EVIDENCIAS_S5.md`.

## Interface gráfica (opcional, no computador do usuário)

```powershell
$env:CRUD_URL_API = "http://10.0.99.150:2209/ativos"
$env:CRUD_API_KEY = "mesma chave do servidor"
python main.py
```

## Execução sem Docker (desenvolvimento)

```bash
pip install -r requirements-dev.txt
python -m pytest -q
python -m uvicorn api.app_rest:app --reload
```
