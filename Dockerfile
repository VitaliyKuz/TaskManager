FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    build-essential \
    python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt


COPY . .


CMD if [ ! -d "migrations" ]; then flask db init; fi && \
    flask db migrate -m "Initial migration" || true && \
    while ! flask db upgrade; do \
        echo "Database not ready, retrying migration in 5 seconds..." && sleep 5; \
    done && \
    gunicorn -w 4 -b 0.0.0.0:5000 app:app
