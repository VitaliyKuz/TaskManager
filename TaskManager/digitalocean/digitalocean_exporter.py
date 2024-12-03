from flask import Flask, Response
import requests
import os

app = Flask(__name__)

DIGITALOCEAN_API_TOKEN = os.getenv("DO_API_TOKEN")


def fetch_droplet_metrics():
    headers = {"Authorization": f"Bearer {DIGITALOCEAN_API_TOKEN}"}
    response = requests.get("https://api.digitalocean.com/v2/droplets", headers=headers)
    droplets = response.json().get("droplets", [])

    metrics = []
    for droplet in droplets:
        droplet_id = droplet["id"]
        name = droplet["name"]
        region = droplet["region"]["slug"]
        metrics.append(f'digitalocean_droplet_info{{id="{droplet_id}",name="{name}",region="{region}"}} 1')

        # Fetch droplet usage stats (fake example, replace with actual DigitalOcean API call)
        stats_response = requests.get(f"https://api.digitalocean.com/v2/droplets/{droplet_id}/metrics", headers=headers)
        stats = stats_response.json().get("metrics", {})
        cpu = stats.get("cpu", 0)
        memory = stats.get("memory", 0)
        network_in = stats.get("network_in", 0)
        network_out = stats.get("network_out", 0)

        metrics.append(f'digitalocean_droplet_cpu{{id="{droplet_id}"}} {cpu}')
        metrics.append(f'digitalocean_droplet_memory{{id="{droplet_id}"}} {memory}')
        metrics.append(f'digitalocean_droplet_network_in{{id="{droplet_id}"}} {network_in}')
        metrics.append(f'digitalocean_droplet_network_out{{id="{droplet_id}"}} {network_out}')

    return "\n".join(metrics)


@app.route('/metrics')
def metrics():
    metrics_data = fetch_droplet_metrics()
    return Response(metrics_data, mimetype="text/plain")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
