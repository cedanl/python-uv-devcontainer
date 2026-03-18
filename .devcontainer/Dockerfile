FROM python:3.12-slim

# Base tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git curl \
    libpq-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS (needed for npx/skills)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Non-root dev user
RUN useradd -m vscode
USER vscode
WORKDIR /workspace

ENV PATH="/home/vscode/.local/bin:${PATH}"

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash

# Claude / Anthropic environment
ENV CLAUDE_CODE_USE_FOUNDRY=1 \
    ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-6 \
    ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6 \
    ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-6