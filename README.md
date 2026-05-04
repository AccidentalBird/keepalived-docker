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

## Build

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t keepalived-docker .
```

## Why

Most keepalived images are x86-only or carry heavyweight init systems. This image is ~10 MB and runs keepalived directly with no wrapper scripts.

## License

MIT
