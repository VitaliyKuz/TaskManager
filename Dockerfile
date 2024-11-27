# Jenkins base image
FROM jenkins/jenkins:lts as jenkins

# Switch to root to install Docker CLI
USER root

# Install Docker CLI and Docker Compose
RUN apt-get update && apt-get install -y \
    docker.io \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L "https://github.com/docker/compose/releases/download/2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Add Jenkins user to the Docker group
RUN usermod -aG docker jenkins

# Switch back to Jenkins user
USER jenkins

# Python base image for the application
FROM python:3.9-slim as app

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Specify the Gunicorn command
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
