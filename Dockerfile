FROM python:3.9.5-slim

WORKDIR /app

ENV PATH="/root/.local/bin:$PATH"
ENV PYTHONUNBUFFERED=true

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    libgmp-dev \
    libssl-dev \
    python3-dev \
    libpq-dev && \
    apt-get clean && apt-get autoremove -y

COPY ./pyproject.toml ./poetry.lock ./README.md ./

RUN curl -sSL https://install.python-poetry.org | python3.9 -

RUN poetry config virtualenvs.in-project true

RUN python3.9 -m venv .venv && \
    poetry run pip install -U pip setuptools wheel && \
    poetry run pip install torch==2.0.0+cpu --index-url https://download.pytorch.org/whl/cpu --trusted-host download.pytorch.org && \
    poetry install --without dev

RUN rm -rf /root/.cache

COPY ./src ./src

RUN poetry run pip install ./src
