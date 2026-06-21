# syntax=docker/dockerfile:1

FROM python:3.13-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64 \
    PATH="/usr/lib/jvm/temurin-21-jdk-amd64/bin:/app/.venv/bin:${PATH}"

# Install Temurin JDK 21 from the Adoptium repository.
# Bookworm's own repos only ship OpenJDK 17, so we add Adoptium to stay on JDK 21.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
        -o /etc/apt/keyrings/adoptium.asc \
    && chmod 644 /etc/apt/keyrings/adoptium.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
        > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install uv.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Application dependencies live in /app; user code lives in /workspace.
WORKDIR /app

COPY pyproject.toml README.md ./
COPY src ./src

# Pin Python to 3.13 and install the locked dependency tree.
RUN uv python pin 3.13 \
    && uv sync

# Runtime directory for the mounted workspace.
WORKDIR /workspace

# Jupyter Lab + Spark driver UI.
EXPOSE 8888 4040

# Start Jupyter so the container stays alive and exposes the notebook UI.
CMD [ \
    "jupyter", "lab", \
    "--ip=0.0.0.0", \
    "--port=8888", \
    "--no-browser", \
    "--allow-root", \
    "--ServerApp.token=''", \
    "--ServerApp.password=''" \
]
