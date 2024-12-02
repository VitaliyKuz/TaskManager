# Use a base Python image
FROM python:3.12-slim

WORKDIR /app

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata libpq-dev gcc build-essential python3-dev curl unzip && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies
COPY app/requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Expose Flask's port
EXPOSE 5000

# Command to run the application
CMD flask db upgrade && \
    gunicorn -w 4 -b 0.0.0.0:5000 app:app
