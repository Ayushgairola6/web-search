#!/bin/sh
# This script is needed to set the port to 7860 before SearXNG starts.
# It overrides the default port(8080) to match Render's expectations.
export SEARXNG_BIND_ADDRESS = "0.0.0.0:7860"
exec / sbin / tini-- / usr / local / searxng / dockerfiles / docker - entrypoint.sh
