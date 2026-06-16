FROM searxng/searxng:latest

USER root

# 1. Bootstrap pip using Python's built-in ensurepip module
RUN python3 -m ensurepip --upgrade

# 2. Use the new pip to install the rotating-proxy package
RUN python3 -m pip install rotating-proxy

# 3. Download tini (the init system) manually
#    The image's entrypoint expects it at /sbin/tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /sbin/tini
RUN chmod +x /sbin/tini

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
