FROM python:3.12-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /workspace

ENV UV_LINK_MODE=copy
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
ENV UV_NO_CACHE=1

COPY pyproject.toml uv.lock ./

RUN uv sync --locked --no-install-project

COPY . .

ENV PATH="/opt/venv/bin:$PATH"
ENV DBT_PROFILES_DIR=/root/.dbt

ENTRYPOINT ["dbt"]

CMD ["--version"]
