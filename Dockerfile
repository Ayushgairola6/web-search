FROM searxng/searxng:latest

USER root

# Bootstrap pip using Python's built-in ensurepip, then install rotating-proxy
RUN python3 -m ensurepip --upgrade && \
    python3 -m pip install rotating-proxy

# Copy your proxy list and configuration
COPY proxies.txt /etc/searxng/proxies.txt
COPY settings.yml /etc/searxng/settings.yml

# Entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch back to the non‑root user
USER searxng

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
