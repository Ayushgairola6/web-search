FROM searxng/searxng:latest

USER root

# Install pip (if not present) and the rotating-proxy package
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install rotating-proxy && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy your proxy list and configuration
COPY proxies.txt /etc/searxng/proxies.txt
COPY settings.yml /etc/searxng/settings.yml

# Copy and make the entrypoint executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch back to the searxng user (security)
USER searxng

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
