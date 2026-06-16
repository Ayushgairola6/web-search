#!/bin/sh

# Start the Python proxy rotator in the background
python3 /usr/local/bin/proxy_rotator.py &

# Give it a moment to bind the socket
sleep 3

# Tell SearXNG to use our local proxy
export SEARXNG_PROXY="http://localhost:5566"
export SEARXNG_BIND_ADDRESS="0.0.0.0:7860"

# Launch SearXNG directly with our settings file
exec searxng -c /etc/searxng/settings.yml
