# data/

Diretório de dados do projeto `trab02_2026_2_12621cbs209`.

- Em execução, o banco SQLite fica **dentro do volume Docker** `trab02_2026_2_12621cbs209_data`,
  montado em `/app/data` no container (arquivo `/app/data/banco_api.db`).
- Esta pasta, no host, recebe apenas **backups** gerados por `scripts/backup_dados.sh`.
- Nada aqui (exceto este README) vai para o Git nem para a imagem: veja `.gitignore` e `.dockerignore`.
