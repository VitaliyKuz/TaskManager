from flask import Flask, Response
import requests
import os

app = Flask(__name__)

DIGITALOCEAN_API_TOKEN = os.getenv("DO_API_TOKEN")


def fetch_droplet_metrics():
    headers = {"Authorization": f"Bearer {DIGITALOCEAN_API_TOKEN}"}
    response = requests.get("https://api.digitalocean.com/v2/droplets", headers=headers)
    if response.status_code != 200:
        return f"# ERROR: Unable to fetch droplets: {response.text}"

    droplets = response.json().get("droplets", [])

    metrics = []
    for droplet in droplets:
        droplet_id = droplet["id"]
        name = droplet["name"]
        region = droplet["region"]["slug"]

        metrics.append(f'digitalocean_droplet_info{{id="{droplet_id}",name="{name}",region="{region}"}} 1')

        # Example: Add real API metrics if available
        cpu = droplet.get("cpu", 0)
        memory = droplet.get("memory", 0)
        disk = droplet.get("disk", 0)

        metrics.append(f'digitalocean_droplet_cpu{{id="{droplet_id}"}} {cpu}')
        metrics.append(f'digitalocean_droplet_memory{{id="{droplet_id}"}} {memory}')
        metrics.append(f'digitalocean_droplet_disk{{id="{droplet_id}"}} {disk}')

    return "\n".join(metrics)


@app.route('/metrics')
def metrics():
    metrics_data = fetch_droplet_metrics()
    return Response(metrics_data, mimetype="text/plain")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
