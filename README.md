# keepalived-docker

Minimal Alpine-based Docker image for [keepalived](https://www.keepalived.org/), built for multi-arch (amd64 + arm64).

## Pull

```bash
docker pull ghcr.io/accidentalbird/keepalived-docker:latest
```

## Usage

Mount your keepalived config and run:

```bash
docker run -d \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add NET_BROADCAST \
  --cap-add NET_RAW \
  -v /etc/keepalived/keepalived.conf:/etc/keepalived/keepalived.conf:ro \
  ghcr.io/accidentalbird/keepalived-docker:latest
```

## Docker Compose

See [`compose.example.yaml`](compose.example.yaml) for a full example. Minimal config:

```yaml
services:
  keepalived:
    image: ghcr.io/accidentalbird/keepalived-docker:latest
    container_name: keepalived
    restart: always
    network_mode: host
    cap_add:
      - NET_ADMIN
      - NET_BROADCAST
      - NET_RAW
    volumes:
      - /etc/keepalived/keepalived.conf:/etc/keepalived/keepalived.conf:ro
```

## Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest build from `main` |
| `sha-<commit>` | Pinned to a specific commit |

## Security

**Required capabilities:** keepalived uses VRRP, which requires `NET_ADMIN`, `NET_BROADCAST`, and `NET_RAW` to manage virtual IPs on the host network interface. These cannot be dropped — they are architectural requirements of the protocol, not artifacts of this image.

**Script user:** The image creates a `keepalived_script` user (no login, no home directory). Health check scripts run as this user, not root. Your keepalived config should include:

```
global_defs {
    enable_script_security
}

vrrp_script check_something {
    script "/check.sh"
    user keepalived_script
}
```

**Script permissions:** Any script mounted into the container must be executable and readable by all users:

```bash
chmod a+rx /path/to/check.sh
```

**Vulnerability scanning:** Every build is scanned with [Trivy](https://github.com/aquasecurity/trivy). Results are published to the GitHub Security tab. Base image updates are automated via Dependabot.

## Build

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t keepalived-docker .
```

## Why

Most keepalived images are x86-only or carry heavyweight init systems. This image is ~10 MB and runs keepalived directly with no wrapper scripts.

## License

MIT
