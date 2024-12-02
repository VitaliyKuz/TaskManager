FROM python:3.12-slim

WORKDIR /app

# Встановлюємо системні залежності, включаючи aws-cli
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    build-essential \
    python3-dev \
    curl \
    unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/ \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Копіюємо залежності Python та встановлюємо їх
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Копіюємо код програми
COPY . .

# Команди для Flask і міграцій
CMD if [ ! -d "migrations" ]; then flask db init; fi && \
    flask db migrate -m "Initial migration" || true && \
    while ! flask db upgrade; do \
        echo "Database not ready, retrying migration in 5 seconds..." && sleep 5; \
    done && \
    gunicorn -w 4 -b 0.0.0.0:5000 app:app
