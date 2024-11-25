FROM mcr.microsoft.com/vscode/devcontainers/python:3.11
ARG USERNAME=vscode

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && \
  apt-get install -y --no-install-recommends libgdal-dev && \
  rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install pipx --no-cache-dir
RUN python3 -m pipx ensurepath
RUN pipx install rust-just

WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --group dev --group tests

# Then, add the rest of the project source code and install it
# Installing separately from its dependencies allows optimal layer caching
COPY . /app

RUN --mount=type=cache,target=/root/.cache/uv \
   uv sync --frozen --no-dev

ENV UV_CACHE_DIR=/app/.cache/uv
RUN mkdir -p $UV_CACHE_DIR && chown -R $USERNAME $UV_CACHE_DIR && chmod -R 760 $UV_CACHE_DIR
COPY . .

RUN --mount=type=cache,target=$UV_CACHE_DIR \
    ["uv", "pip", "install", "-e", ".[duckdb,clickhouse,examples,geospatial]"]

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

SHELL ["/bin/bash", "-c", "source /app/.venv/bin/activate"]

USER $USERNAME