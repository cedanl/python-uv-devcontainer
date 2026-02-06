FROM python:3.12-slim

# Basis tooling + wat je vaak nodig hebt
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Niet-root user voor dev
RUN useradd -m vscode
USER vscode
WORKDIR /workspace

# uv installeren (user-local)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/vscode/.local/bin:${PATH}"