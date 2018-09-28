# Jaeger collector

The Jaeger collector processes and stores traces obtained from the Jaeger agents.

This repository contains our jaeger-collector dockerfile. For our needs, it makes sense to have as little dynamic parts as possible. We only need to manage the Jaeger collector's configuration.

## Building the dockerfile

We recommend running the build tasks via our deployment procedure, but in case you want to build it yourself, there are many build arguments to pass. You can learn about them by reading the dockerfile.

## Running jaeger-collector

Depending on the config repo, the container could expect some names to be reachable. Refer to the specifics of the configuration repo.

An example run command should look like

```Bash
# Run the container
docker run --rm -it --net=ct_bridge --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name jaeger-collector cloudtrust-jaeger-collector
```

Note that the storage backend must be available and correctly configured, otherwise the Jaeger collector won't work. We use the Cloudtrust [elasticsearch-service](https://github.com/cloudtrust/elasticsearch-service) for the storage.

## Configuration

The Jaeger collector is configured with the file `deploy/etc/jaeger-collector/collector.yml` from the [configuration](https://github.com/cloudtrust/dev-config) repository.
