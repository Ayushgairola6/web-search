FROM searxng/searxng:latest

# Set bind address and port
ENV SEARXNG_BIND_ADDRESS=0.0.0.0:7860

# Copy your custom settings
COPY settings.yml /etc/searxng/settings.yml

# Health check (use the correct port)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

EXPOSE 7860
