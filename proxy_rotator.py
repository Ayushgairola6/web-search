#!/usr/bin/env python3
import random
import socket
import select
import urllib.parse
import sys
import time

PROXY_LIST_FILE = '/etc/searxng/proxies.txt'

def load_proxies():
    with open(PROXY_LIST_FILE, 'r') as f:
        return [line.strip() for line in f if line.strip()]

def parse_proxy(proxy_str):
    if not proxy_str.startswith('http://'):
        proxy_str = 'http://' + proxy_str
    parsed = urllib.parse.urlparse(proxy_str)
    return (parsed.hostname, parsed.port or 80)

def handle_request(client_sock, proxies):
    # Read request headers
    request = b''
    while b'\r\n\r\n' not in request:
        data = client_sock.recv(4096)
        if not data:
            return
        request += data

    lines = request.split(b'\r\n')
    if not lines:
        return
    first_line = lines[0].decode()
    parts = first_line.split()
    if len(parts) < 2:
        return
    method, url = parts[0], parts[1]

    # Determine target host and path
    if url.startswith(b'http://') or url.startswith(b'https://'):
        parsed_url = urllib.parse.urlparse(url.decode())
        host = parsed_url.netloc
        path = parsed_url.path or '/'
        if parsed_url.query:
            path += '?' + parsed_url.query
        scheme = parsed_url.scheme
    else:
        # CONNECT or relative path – extract Host from header
        host_header = None
        for line in lines[1:]:
            if line.lower().startswith(b'host:'):
                host_header = line.split(b':', 1)[1].strip().decode()
                break
        if not host_header:
            return
        host = host_header
        path = url.decode()
        scheme = 'http'

    # Pick a random proxy from the list
    proxy = random.choice(proxies)
    proxy_host, proxy_port = parse_proxy(proxy)

    # Handle CONNECT (HTTPS tunneling)
    if method == 'CONNECT':
        try:
            remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            remote.connect((proxy_host, proxy_port))
            remote.send(request)
            response = b''
            while b'\r\n\r\n' not in response:
                data = remote.recv(4096)
                if not data:
                    break
                response += data
            if b'200' not in response:
                remote.close()
                return
            client_sock.send(response)
            # Tunnel
            client_sock.setblocking(0)
            remote.setblocking(0)
            while True:
                rlist, _, _ = select.select([client_sock, remote], [], [])
                for sock in rlist:
                    if sock is client_sock:
                        data = client_sock.recv(4096)
                        if not data:
                            return
                        remote.send(data)
                    else:
                        data = remote.recv(4096)
                        if not data:
                            return
                        client_sock.send(data)
        except Exception as e:
            print("CONNECT error:", e, file=sys.stderr)
        finally:
            remote.close()
        return

    # Regular HTTP request
    if url.startswith(b'http://') or url.startswith(b'https://'):
        forward_url = url.decode()
    else:
        forward_url = f"{scheme}://{host}{path}"

    new_request = f"{method} {forward_url} HTTP/1.1\r\n"
    host_added = False
    for line in lines[1:]:
        if line.strip() == b'':
            continue
        if line.lower().startswith(b'host:'):
            host_added = True
        new_request += line.decode() + '\r\n'
    if not host_added:
        new_request += f"Host: {host}\r\n"
    new_request += '\r\n'

    try:
        remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote.connect((proxy_host, proxy_port))
        remote.send(new_request.encode())
        while True:
            data = remote.recv(4096)
            if not data:
                break
            client_sock.send(data)
    except Exception as e:
        print("HTTP error:", e, file=sys.stderr)
    finally:
        remote.close()

def main():
    proxies = load_proxies()
    if not proxies:
        print("No proxies found – exiting.", file=sys.stderr)
        sys.exit(1)
    print(f"Loaded {len(proxies)} proxies")

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', 5566))
    server.listen(10)
    print("Proxy rotator listening on port 5566")

    while True:
        client, addr = server.accept()
        try:
            handle_request(client, proxies)
        except Exception as e:
            print("Error handling request:", e, file=sys.stderr)
        finally:
            client.close()

if __name__ == '__main__':
    main()
