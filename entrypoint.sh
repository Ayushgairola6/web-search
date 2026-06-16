#!/bin/sh

# This script starts the rotating proxy, then launches SearXNG.

# 1. Start the rotating proxy on port 5566 (local)
#    It will read proxies from /etc/searxng/proxies.txt and rotate them.
echo "Starting rotating proxy on port 5566..."
rotating-proxy --proxy-list /etc/searxng/proxies.txt --port 5566 &

# 2. Give the proxy a moment to start up
sleep 3

# 3. Tell SearXNG to use our local rotating proxy
export SEARXNG_PROXY="http://localhost:5566"

# 4. Set the bind address to 0.0.0.0:7860 (as before)
export SEARXNG_BIND_ADDRESS="0.0.0.0:7860"

# 5. Execute the original SearXNG Docker entrypoint
exec /sbin/tini -- /usr/local/searxng/dockerfiles/docker-entrypoint.sh
