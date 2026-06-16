#!/bin/sh

# Start the Python proxy rotator in the background
python3 /usr/local/bin/proxy_rotator.py &

# Give it a moment to bind the socket
sleep 3

# Tell SearXNG to use our local proxy
export SEARXNG_PROXY="http://localhost:5566"
export BIND_ADDRESS="0.0.0.0:7860"

# Find the actual entrypoint script
ENTRYPOINT_PATH=$(find / -name "docker-entrypoint.sh" 2>/dev/null | head -n1)

if [ -n "$ENTRYPOINT_PATH" ]; then
    exec /sbin/tini -- "$ENTRYPOINT_PATH"
else
    # Fallback: try running with python -m searxng
    exec python3 -m searxng
fi
