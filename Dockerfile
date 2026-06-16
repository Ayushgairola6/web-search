FROM searxng/searxng:2025.2.15-d4972f1c2

# Copy the proxy rotator script and your proxy list
COPY proxy_rotator.py /usr/local/bin/proxy_rotator.py
COPY proxies.txt /etc/searxng/proxies.txt

# Make the script executable
RUN chmod +x /usr/local/bin/proxy_rotator.py

# Copy your custom settings
COPY settings.yml /etc/searxng/settings.yml

# Custom entrypoint that starts the proxy rotator then launches SearXNG
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
