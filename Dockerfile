FROM python:3.12-slim AS producao
LABEL org.opencontainers.image.title="trab02_2026_2_12621cbs209" \
      org.opencontainers.image.version="5.0" \
      org.opencontainers.image.authors="Felipe Silva Faria"
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    CRUD_REPOSITORIO=sqlite \
    CRUD_ARQUIVO=/app/data/banco_api.db \
    CRUD_LOGS=/app/logs \
    CRUD_LOG_JSON=1
WORKDIR /app
RUN groupadd --system app && useradd --system --gid app --no-create-home app
COPY requirements-docker.txt .
RUN pip install -r requirements-docker.txt
COPY config.py ./
COPY api/ ./api/
COPY algoritmos/ ./algoritmos/
COPY dominio/ ./dominio/
COPY estruturas/ ./estruturas/
COPY persistencia/ ./persistencia/
COPY servicos/ ./servicos/
COPY utilitarios/ ./utilitarios/
RUN mkdir -p /app/data /app/logs && chown -R app:app /app/data /app/logs
USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["python", "-c", "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2).status == 200 else 1)"]
CMD ["uvicorn", "api.app_rest:app", "--host", "0.0.0.0", "--port", "8000"]

FROM producao AS testes
USER root
RUN pip install pytest httpx
COPY tests/ ./tests/
USER app
ENV CRUD_LOGS=/tmp/logs CRUD_LOG_JSON=0
CMD ["python", "-m", "pytest", "-q", "-p", "no:cacheprovider", "tests"]
