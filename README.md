
docker build --build-arg jaeger_collector_git_tag=initial -t cloudtrust-jaeger-collector -f cloudtrust-jaeger-collector.dockerfile .
docker create --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 14268:14268 --name jaeger-collector-1 cloudtrust-jaeger-collector
