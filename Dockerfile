# Використання базового образу Python для Flask
FROM python:3.9-slim as app_base

# Робочий каталог для Flask
WORKDIR /app

# Копіювання та встановлення залежностей
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Копіювання коду додатка
COPY . .

# Використання Gunicorn для запуску Flask
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]

# Jenkins образ
FROM jenkins/jenkins:lts-jdk11 as jenkins_base

# Перехід до root для встановлення Docker
USER root

# Встановлення Docker CLI та docker-compose plugin
RUN apt-get update && apt-get install -y \
    docker.io \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Додавання Jenkins до групи Docker
RUN usermod -aG docker jenkins

# Повернення до користувача Jenkins
USER jenkins

# Робочий каталог для Jenkins
WORKDIR /var/jenkins_home

# Jenkins запускається автоматично
