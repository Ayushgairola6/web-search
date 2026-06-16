FROM searxng/searxng:latest

USER root

# 使用 apk 代替 apt-get 安装 python3-pip (Alpine 中包名为 py3-pip)
RUN apk add --no-cache py3-pip && \
    pip3 install rotating-proxy

# 复制你的代理列表和配置文件
COPY proxies.txt /etc/searxng/proxies.txt
COPY settings.yml /etc/searxng/settings.yml

# 复制并设置入口脚本的执行权限
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 切换回 searxng 用户 (安全考虑)
USER searxng

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:7860/healthz || exit 1

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
