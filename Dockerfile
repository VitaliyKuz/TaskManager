# Використання легкого базового образу
FROM python:3.12-slim

WORKDIR /app

# Встановлення тільки необхідних системних залежностей
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev gcc build-essential python3-dev curl unzip tzdata \
    && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Встановлення Python-залежностей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копіювання коду додатка
COPY . .

# Вказівка основної команди для запуску додатка
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
