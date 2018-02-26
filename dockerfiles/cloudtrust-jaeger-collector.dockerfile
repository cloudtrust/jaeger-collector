FROM cloudtrust-baseimage:f27

ARG jaeger_collector_git_tag
ARG jaeger_release
ARG config_env
ARG config_git_tag
ARG config_repo

# Get dependencies and put jaeger collector where we expect it to be
RUN dnf -y install wget && \
    dnf clean all

RUN groupadd collector && \
    useradd -m -s /sbin/nologin -g collector collector && \
    install -d -v -m755 /etc/collector/ -o collector -g collector

WORKDIR /cloudtrust
RUN wget ${jaeger_release} && \
    tar -xzf v1.2.0.tar.gz && \
    mv -v v1.2.0 jaeger && \
    install -v -m0755 jaeger/collector-linux /etc/collector/collector && \
    rm v1.2.0.tar.gz && \
    rm -rf jaeger/

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/jaeger-collector.git && \
    git clone ${config_repo} ./config

WORKDIR /cloudtrust/jaeger-collector
RUN git checkout ${jaeger_collector_git_tag} && \
    install -v -m0644 deploy/etc/security/limits.d/* /etc/security/limits.d/ && \
# monit
    install -v -m0644 deploy/etc/monit.d/* /etc/monit.d/ && \
# jaeger collector
    install -v -o collector -g collector -m 644 deploy/etc/systemd/system/collector.service /etc/systemd/system/collector.service && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/collector.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/collector.service.d/limit.conf /etc/systemd/system/collector.service.d/limit.conf

WORKDIR /cloudtrust/config
RUN git checkout ${config_git_tag} && \
    install -v -m0755 -o collector -g collector deploy/${config_env}/etc/jaeger-collector/collector.yml /etc/collector/  

# enable services
RUN systemctl enable collector.service && \
    systemctl enable monit.service