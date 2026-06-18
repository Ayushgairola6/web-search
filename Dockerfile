FROM searxng/searxng:latest

COPY settings.yml /etc/searxng/settings.yml

# Add a proper health check for Render
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

EXPOSE 7860
