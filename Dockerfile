FROM searxng/searxng:latest

# Add a proper health check for Render
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

# Use a custom entrypoint to set the correct port
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy the SearXNG configuration file
COPY settings.yml /etc/searxng/settings.yml

EXPOSE 7860
ENTRYPOINT ["/entrypoint.sh"]