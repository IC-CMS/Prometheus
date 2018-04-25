#Currently can use the standard prometheus image
#If we need to expand the dockerfile setup, use this file

ARG CODE_VERSION=latest
FROM prom/prometheus:${CODE_VERSION}
LABEL maintainer="sredna"

LABEL RUN="docker run -d -p 9090:9090 -v config/prometheus.yml:/etc/prometheus/prometheus.yml \
        -v config/alert.rules:/etc/prometheus/alert.rules \
        sredna/prometheus" \

      RECOMMENDED="Supply an external volume for the data store for easy upgrade and maintinance \
      remote_write and remote_read are also recommended for large systems"

