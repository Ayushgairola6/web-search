#!/bin/sh

# Start the Python proxy rotator in the background
python3 /usr/local/bin/proxy_rotator.py &

# Wait a moment for the socket to bind
sleep 3

# Tell SearXNG to use our local proxy
export SEARXNG_PROXY="http://localhost:5566"
export SEARXNG_BIND_ADDRESS="0.0.0.0:7860"

# Now launch SearXNG. The official image's CMD is "/usr/local/searxng/dockerfiles/docker-entrypoint.sh"
# but we can also just run the searxng command directly.
exec /usr/local/searxng/dockerfiles/docker-entrypoint.sh
