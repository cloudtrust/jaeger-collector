# Jaeger collector
Jaeger collector is a docker container containing the Jaeger collector. It processes and stores traces traces obtained from the agents.

![tracing](https://github.com/cloudtrust/doc/tree/gh-pages/graphics/tracing.png)

## Configuration

The collector configuration file is in `https://github.com/cloudtrust/dev-config/blob/master/deploy/int/etc/jaeger-collector/collector.yml`.

## Build

```bash
mkdir build_context
cp dockerfiles/cloudtrust-jaeger-collector.dockerfile build_context/
# Build image
docker build --build-arg jaeger_collector_git_tag=<jaeger_collector_git_tag> --build-arg jaeger_release=<jaeger_release> --build-arg config_git_tag=<config_git_tag> --build-arg config_repo=<config_repo> -t cloudtrust-jaeger-collector -f cloudtrust-jaeger-collector.dockerfile .
# Create container
docker create --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 14267:14267 --name jaeger-collector-1 cloudtrust-jaeger-collector
```

## Usage
Start the collector container: 
```bash
docker start jaeger-collector-1
```

Note that the storage backend must be available and correctly configured, otherwise the Jaeger collector won't work.

