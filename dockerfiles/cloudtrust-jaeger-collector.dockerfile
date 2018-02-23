FROM cloudtrust-baseimage:f27

ARG jaeger_collector_git_tag
ARG jaeger_collector_url

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/jaeger-collector.git
ADD ./collector-linux /cloudtrust/collector

WORKDIR /cloudtrust/jaeger-collector
RUN git checkout ${jaeger_collector_git_tag} && \
    groupadd collector && \
    useradd -m -s /sbin/nologin -g collector collector && \
    install -v -m0644 deploy/etc/security/limits.d/* /etc/security/limits.d/ && \
# monit
    install -v -m0644 deploy/etc/monit.d/* /etc/monit.d/ && \    
# jaeger collector
    install -d -v -m755 /etc/collector/ -o collector -g collector && \
    install -v -m0755 deploy/etc/collector/* /etc/collector/ && \
    install -v -m0755 /cloudtrust/collector /etc/collector/ && \
    chown collector:collector /etc/collector/collector && \
    install -v -o collector -g collector -m 644 deploy/etc/systemd/system/collector.service /etc/systemd/system/collector.service && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/collector.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/collector.service.d/limit.conf /etc/systemd/system/collector.service.d/limit.conf && \
# enable services
    systemctl enable collector.service && \
    systemctl enable monit.service

EXPOSE 14268