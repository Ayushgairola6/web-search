FROM searxng/searxng:latest

USER root

# 1. Bootstrap pip and install rotating-proxy
RUN python3 -m ensurepip --upgrade && \
    python3 -m pip install rotating-proxy

# 2. Ensure rotating-proxy is in PATH (link it to /usr/local/bin)
RUN ln -s $(python3 -c "import site; print(site.getusersitepackages())")/../bin/rotating-proxy /usr/local/bin/rotating-proxy || \
    ln -s /usr/local/bin/rotating-proxy /usr/bin/rotating-proxy || true

# 3. Locate the original SearXNG entrypoint script and copy it to a known location
RUN ORIG_ENTRY=$(find / -name "docker-entrypoint.sh" 2>/dev/null | head -n1) && \
    if [ -n "$ORIG_ENTRY" ]; then \
        cp "$ORIG_ENTRY" /original-entrypoint.sh && \
        chmod +x /original-entrypoint.sh; \
    else \
        echo "Original entrypoint not found – falling back to direct start" && \
        echo '#!/bin/sh\nexec searxng' > /original-entrypoint.sh && \
        chmod +x /original-entrypoint.sh; \
    fi

# 4. Download tini (if not already present)
RUN if [ ! -f /sbin/tini ]; then \
        curl -Lo /sbin/tini https://github.com/krallin/tini/releases/download/v0.19.0/tini && \
        chmod +x /sbin/tini; \
    fi

# Copy your proxy list and settings
COPY proxies.txt /etc/searxng/proxies.txt
COPY settings.yml /etc/searxng/settings.yml

# Custom entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER searxng

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
