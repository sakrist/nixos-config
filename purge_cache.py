import requests
import sys

def main(zoneid, token):
    print("Clearing Cloudflare cache...")

    url = f"https://api.cloudflare.com/client/v4/zones/{zoneid}/purge_cache"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}"
    }
    data = '{"purge_everything": true}'

    response = requests.post(url, headers=headers, data=data)

    if response.status_code == 200:
        print("Cache purged successfully. It will take 30 seconds to reflect.")
    else:
        print(f"Failed to purge cache. Status code: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python purge_cache.py <zoneid> <token>")
        exit(1)
    
    zoneid = sys.argv[1]
    token = sys.argv[2]
    main(zoneid, token)
