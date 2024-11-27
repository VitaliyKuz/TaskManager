# Базовий образ для Jenkins
FROM jenkins/jenkins:lts as jenkins_base

# Перехід до root-користувача для встановлення залежностей
USER root

# Встановлення Docker CLI, Docker Compose, Python та інших інструментів
RUN apt-get update && apt-get install -y \
    docker.io \
    docker-compose-plugin \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Додавання Jenkins користувача до групи Docker
RUN usermod -aG docker jenkins

# Підготовка Python-залежностей
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# Повернення до користувача Jenkins
USER jenkins

# Робочий каталог для Jenkins
WORKDIR /app

# Копіювання файлів додатка
COPY . .

# Команда для запуску Gunicorn (Flask-додатка)
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
