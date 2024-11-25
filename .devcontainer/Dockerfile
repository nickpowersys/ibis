FROM mcr.microsoft.com/vscode/devcontainers/python:3.11
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN adduser --system --no-create-home nonroot
# Create the user
#RUN groupadd --gid $USER_GID $USERNAME \
#RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME 
    #\
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
# RUN sudo apt-get update \
#      && sudo apt-get install -y sudo \
#      && sudo echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#      && sudo chmod 0440 /etc/sudoers.d/$USERNAME


# SHELL ["/bin/bash", "-c"]
# RUN apt-get update && apt-get install -y \
#      && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#      && chmod 0440 /etc/sudoers.d/$USERNAME
# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.


COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

#SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
  apt-get install -y --no-install-recommends libgdal-dev

RUN python3 -m pip install pipx
RUN python3 -m pipx ensurepath
RUN pipx install rust-just

WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Install the project's dependencies using the lockfile and settings
#SHELL ["/bin/bash", "-c"]
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

#SHELL ["/bin/bash", "-c"]
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --group dev --group tests

# Then, add the rest of the project source code and install it
# Installing separately from its dependencies allows optimal layer caching
COPY . /app
#SHELL ["/bin/bash", "-c"]
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

ENV UV_CACHE_DIR=/app/.cache/uv
RUN mkdir -p $UV_CACHE_DIR
COPY . .
# is this needed? it was used when builds were working prior to 5:45 pm. when it was
# revmoed (and also the mount cache dir was changed, tests broke)

#SHELL ["/bin/bash", "-c"]
RUN --mount=type=cache,target=$UV_CACHE_DIR \
    ["uv", "pip", "install", "-e", ".[duckdb,clickhouse,examples,geospatial]"]

#RUN --mount=type=cache,target=/root/.cache/uv \
#    ["uv", "pip", "install", "-e", ".[duckdb,clickhouse,examples,geospatial]"]

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

#RUN source /app/.venv/bin/activate


SHELL ["/bin/bash", "-c", "source /app/.venv/bin/activate"]
#RUN ["source /app/.venv/bin/activate"]

#USER nonroot
