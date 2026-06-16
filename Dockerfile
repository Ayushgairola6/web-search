FROM searxng/searxng:latest

# Install Python3 + pip (if not already present) and the rotating-proxy package
USER root
RUN apk add --no-cache python3 py3-pip && \
    pip3 install rotating-proxy

# Copy your proxy list
COPY proxies.txt /etc/searxng/proxies.txt

# Copy your custom settings (same as before)
COPY settings.yml /etc/searxng/settings.yml

# Copy the updated entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch back to the searxng user for the main process
USER searxng

# Healthcheck (unchanged)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
