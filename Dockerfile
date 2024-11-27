# Базовий образ Python для Flask
FROM python:3.9-slim AS flask_base

# Встановлення робочого каталогу
WORKDIR /app

# Копіюємо та встановлюємо залежності Flask
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Копіюємо код програми
COPY . .

# Jenkins базовий образ
FROM jenkins/jenkins:lts-jdk11 AS jenkins_base

# Перехід до root для встановлення Docker CLI та Docker Compose
USER root

# Встановлення Docker CLI та Docker Compose
RUN apt-get update && apt-get install -y \
    docker.io \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Додавання користувача Jenkins до групи Docker
RUN usermod -aG docker jenkins

# Повернення до користувача Jenkins
USER jenkins

# Основний образ для запуску контейнерів
FROM python:3.9-slim

# Копіюємо Flask та Jenkins з попередніх етапів
COPY --from=flask_base /app /app
COPY --from=jenkins_base /var/jenkins_home /var/jenkins_home

# Встановлення PostgreSQL, Prometheus, Grafana
USER root
RUN apt-get update && apt-get install -y \
    postgresql \
    prometheus \
    grafana \
    && rm -rf /var/lib/apt/lists/*

# Налаштування PostgreSQL
RUN service postgresql start && \
    su postgres -c "psql --command \"CREATE USER user WITH SUPERUSER PASSWORD '1';\"" && \
    su postgres -c "createdb -O user tasks_db"

# Відкриття портів для Flask, PostgreSQL, Prometheus, Grafana, Jenkins
EXPOSE 5000 5432 9090 3000 8080 50000

# Запуск сервісів
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
