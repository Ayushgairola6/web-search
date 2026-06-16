FROM searxng/searxng:latest

USER root

# Install rotating-proxy using uv (system‑wide)
RUN uv pip install --system rotating-proxy

# Copy your proxy list and settings
COPY proxies.txt /etc/searxng/proxies.txt
COPY settings.yml /etc/searxng/settings.yml

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER searxng

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
