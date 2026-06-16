#!/bin/sh

# Start the proxy rotator on port 5566
rotating-proxy --proxy-list /etc/searxng/proxies.txt --port 5566 &

# Give it a moment to bind
sleep 3

# Tell SearXNG to use our local proxy
export SEARXNG_PROXY="http://localhost:5566"
export SEARXNG_BIND_ADDRESS="0.0.0.0:7860"

# Execute the original SearXNG Docker entrypoint
exec /sbin/tini -- /usr/local/searxng/dockerfiles/docker-entrypoint.sh
