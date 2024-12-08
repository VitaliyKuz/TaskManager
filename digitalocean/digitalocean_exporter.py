from flask import Flask, Response
import requests
import os
import time
import logging

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

DIGITALOCEAN_API_TOKEN = os.getenv("DO_API_TOKEN")
if not DIGITALOCEAN_API_TOKEN:
    logging.error("DO_API_TOKEN is not set. Please configure it as a Jenkins Credential.")

def fetch_droplet_metrics():
    headers = {"Authorization": f"Bearer {DIGITALOCEAN_API_TOKEN}"}
    start_time = time.time()
    try:
        response = requests.get("https://api.digitalocean.com/v2/droplets", headers=headers)
    except requests.exceptions.RequestException as e:
        logging.error(f"Error fetching droplet metrics: {e}")
        return "# ERROR: Failed to fetch droplet metrics."

    api_response_time = time.time() - start_time
    metrics = [f'digitalocean_api_response_time_seconds {api_response_time}']

    if response.status_code != 200:
        metrics.append(f'# ERROR: Unable to fetch droplets: {response.text}')
        return "\n".join(metrics)

    droplets = response.json().get("droplets", [])
    for droplet in droplets:
        droplet_id = droplet["id"]
        name = droplet["name"]
        region = droplet["region"]["slug"]
        metrics.append(f'digitalocean_droplet_info{{id="{droplet_id}",name="{name}",region="{region}"}} 1')

        cpu = droplet.get("cpu", 0)
        memory = droplet.get("memory", 0)
        disk = droplet.get("disk", 0)

        metrics.append(f'digitalocean_droplet_cpu{{id="{droplet_id}"}} {cpu}')
        metrics.append(f'digitalocean_droplet_memory{{id="{droplet_id}"}} {memory}')
        metrics.append(f'digitalocean_droplet_disk{{id="{droplet_id}"}} {disk}')

    return "\n".join(metrics)

@app.route('/metrics')
def metrics():
    if not DIGITALOCEAN_API_TOKEN:
        return Response("# ERROR: DO_API_TOKEN not set.", mimetype="text/plain")
    metrics_data = fetch_droplet_metrics()
    return Response(metrics_data, mimetype="text/plain")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
