#!/bin/bash

source ./venv/bin/activate
source .env
# Ensure required Python dependencies are installed
pip install --quiet requests

version=$(python3 ./get_version.py $GH_USERNAME $GH_BLOG_IMAGE_NAME $GH_TOKEN)
echo "Version: $version"
if [ $? -ne 0 ]; then
    echo "Failed to get version"
    exit 1
fi

echo "Deploying version $version"

kubectl --server=https://192.168.0.99:6443 set image deployment/blog-hugo blog-hugo=ghcr.io/$GH_USERNAME/$GH_BLOG_IMAGE_NAME:$version -n blog-hugo
kubectl --server=https://192.168.0.99:6443 rollout status deployment/blog-hugo -n blog-hugo


python3 purge_cache.py $CLOUDFLARE_ZONEID $CLOUDFLARE_API_TOKEN