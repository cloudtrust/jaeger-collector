FROM cloudtrust-baseimage:f27

ARG jaeger_collector_git_tag
ARG jaeger_release
ARG config_git_tag
ARG config_repo

ARG nginx_version=1.12.1-1.fc27

###
###  Prepare the system stuff
###

RUN dnf -y install nginx-$nginx_version && \
    dnf clean all

RUN groupadd collector && \
    useradd -m -s /sbin/nologin -g collector collector && \
    install -d -v -m755 /opt/collector -o root -g root && \
    install -d -v -m755 /etc/collector -o collector -g collector

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/jaeger-collector.git && \
    git clone ${config_repo} ./config

WORKDIR /cloudtrust/jaeger-collector
RUN git checkout ${jaeger_collector_git_tag}

WORKDIR /cloudtrust/jaeger-collector
RUN install -v -m0644 deploy/etc/security/limits.d/* /etc/security/limits.d/ && \
    install -v -m0644 deploy/etc/monit.d/* /etc/monit.d/ && \
    install -v -m0644 -D deploy/etc/nginx/conf.d/* /etc/nginx/conf.d/ && \
    install -v -m0644 deploy/etc/nginx/nginx.conf /etc/nginx/nginx.conf && \
    install -v -m0644 deploy/etc/nginx/mime.types /etc/nginx/mime.types && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/nginx.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/nginx.service.d/limit.conf /etc/systemd/system/nginx.service.d/limit.conf

##
##  Jaeger collector
##

WORKDIR /cloudtrust
RUN wget ${jaeger_release} -O jaeger.tar.gz && \
    mkdir jaeger && \
    tar -xzf jaeger.tar.gz -C jaeger --strip-components 1 && \
    install -v -m 755 jaeger/collector-linux /opt/collector/collector && \
    rm jaeger.tar.gz && \
    rm -rf jaeger/

WORKDIR /cloudtrust/jaeger-collector
RUN install -v -o collector -g collector -m 644 deploy/etc/systemd/system/collector.service /etc/systemd/system/collector.service && \
    install -d -v -o root -g root -m 644 /etc/systemd/system/collector.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/collector.service.d/limit.conf /etc/systemd/system/collector.service.d/limit.conf

##
##  Config
##

WORKDIR /cloudtrust/config
RUN git checkout ${config_git_tag}

WORKDIR /cloudtrust/config
RUN install -v -m0755 -o collector -g collector deploy/etc/jaeger-collector/collector.yml /etc/collector/

##
##  Enable services
##

RUN systemctl enable collector.service && \
    systemctl enable nginx.service && \
    systemctl enable monit.service
