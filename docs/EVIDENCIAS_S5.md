# Evidências — Sprint S5 (UID S5_20)

Projeto: `trab02_2026_2_12621cbs209` — Felipe Silva Faria — matrícula 12621CBS209
Porta externa: 2000 + 209 = **2209** → porta interna **8000**

## 1. Execução local (computador do laboratório)

| Item | Comando | Resultado / arquivo |
|---|---|---|
| Compose válido | `docker compose config --quiet` | |
| Imagem construída | `docker image ls trab02_2026_2_12621cbs209` | |
| Container saudável | `docker compose ps` | |
| Health | `curl.exe http://localhost:2209/health` | |
| Volume criado | `docker volume ls --filter name=trab02_2026_2_12621cbs209` | |
| Persistência | cadastro → `down` → `up -d` → registro continua | |
| Testes | `docker compose --profile testes run --rm testes` | |

## 2. Implantação no servidor

| Item | Comando | Resultado |
|---|---|---|
| Porta livre antes do deploy | `ss -ltn \| grep ':2209 '` | |
| Deploy | `docker compose up -d --build` | |
| Container saudável | `docker compose ps` | |
| Acesso externo | `http://10.0.99.150:2209/health` | |

## 3. Funcionamento por 24 h

| Momento | Data/hora | StartedAt | RestartCount | Saúde | HTTP |
|---|---|---|---|---|---|
| T0 | | | | | |
| T0 + 24 h | | | | | |

Critério: `StartedAt` com mais de 24 h, `RestartCount` = 0, saúde `healthy` e HTTP 200 em todas as amostras de `evidencias/monitor_*.log`.

## 4. Capturas de tela

- [ ] `docker compose ps` local
- [ ] `/docs` aberto no navegador (local)
- [ ] `docker compose ps` no servidor
- [ ] `/health` acessado pela rede da UFU
- [ ] Resultado do monitoramento após 24 h
