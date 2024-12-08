import requests
import os

region = os.environ.get("region")
ring = os.environ.get("ring")
cluster = os.environ.get("cluster")
url = os.environ.get("nginx_url")

print(f"Region: {region}")
print(f"Ring: {ring}")
print(f"Cluster: {cluster}")

response = requests.get(url)

if response.status_code == 200:
    data = response.json()

    tenants = []
    for item in data['tenants']:
        # Match based on region, ring, and cluster
        if item['region'] == region and item['ring'] == ring and item.get('cluster') == cluster:
            tenants.append(item['tenant'])

    if tenants:
        tenant_str = ",".join(tenants)
        os.environ["Customer"] = tenant_str
        print(f"Customer variable set to: {os.environ['Customer']}")
        print(f"##vso[task.setvariable variable=Customer;]{tenant_str}")
    else:
        print(f"No tenants found for Region: {region}, Ring: {ring}, Cluster: {cluster}")
else:
    print(f"Failed to retrieve data from API. Status code: {response.status_code}")

