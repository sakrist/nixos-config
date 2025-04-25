import requests
import sys

def main(username, image, token):
    # Set up headers for authentication
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }

    # API URL
    url = f"https://api.github.com/users/{username}/packages/container/{image}/versions"

    # Make the API request
    response = requests.get(url, headers=headers)

    # Check if the request was successful
    if response.status_code == 200:
        data = response.json()
        
        # Find a version that is not the latest
        if data:
            first_version = data[0]
            tags = first_version.get('metadata', {}).get('container', {}).get('tags', [])
            if 'latest' in tags:
                tags.remove('latest')
            if len(tags) > 0:
                print(tags[0])
            else:
                print("No non-latest versions found.")
                exit(1)
        else:
            print("No versions found.")
            exit(1)
    else:
        print(f"Failed to fetch data. Status code: {response.status_code}")
        exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python get_version.py <username> <image> <token>")
        exit(1)
    
    username = sys.argv[1]
    image = sys.argv[2]
    token = sys.argv[3]
    main(username, image, token)
