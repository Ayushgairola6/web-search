#!/bin/sh

# Check if rotating-proxy is available; if not, try to use the Python module directly
if ! command -v rotating-proxy >/dev/null 2>&1; then
    echo "rotating-proxy not found – trying to run as Python module"
    exec python3 -m rotating_proxy --proxy-list /etc/searxng/proxies.txt --port 5566 &
else
    rotating-proxy --proxy-list /etc/searxng/proxies.txt --port 5566 &
fi

# Wait for the proxy to bind
sleep 3

# Set environment variables
export SEARXNG_PROXY="http://localhost:5566"
export SEARXNG_BIND_ADDRESS="0.0.0.0:7860"

# Execute the original entrypoint (now at /original-entrypoint.sh)
exec /sbin/tini -- /original-entrypoint.sh
