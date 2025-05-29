ARG ALPINE_IMAGE_TAG=3.14
ARG LINKDING_IMAGE_TAG=latest

FROM docker.io/alpine:$ALPINE_IMAGE_TAG as builder

ARG LITESTREAM_VERSION=v0.3.13
# Download the static build of Litestream directly into the path & make it executable.
# This is done in the builder and copied as the chmod doubles the size.
ADD https://github.com/benbjohnson/litestream/releases/download/$LITESTREAM_VERSION/litestream-$LITESTREAM_VERSION-linux-amd64.tar.gz /tmp/litestream.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz

# Pull linkding docker image.
FROM docker.io/sissbruecker/linkding:$LINKDING_IMAGE_TAG

# Copy Litestream from builder.
COPY --from=builder /usr/local/bin/litestream /usr/local/bin/litestream

# Copy Litestream configuration file.
COPY etc/litestream.yml /etc/litestream.yml

# Copy custom uwsgi. This allows to run with 256MB RAM.
COPY uwsgi.ini /etc/linkding/uwsgi.ini

# Copy startup script and make it executable.
COPY scripts/run.sh /scripts/run.sh
COPY scripts/backup.sh /scripts/backup.sh
COPY scripts/spaces-lifecycle.json /scripts/spaces-lifecycle.json
RUN chmod +x /scripts/run.sh
RUN chmod +x /scripts/backup.sh

# Copy cron configuration
COPY crontab /etc/linkding/crontab

# Install cron, SQLite, unzip, and Vim
RUN apt-get update && \
  apt-get install -y cron && \
  apt-get install sqlite3 && \
  apt-get install unzip && \
  apt-get install -y vim

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install

# Litestream spawns linkding's webserver as subprocess.
CMD ["/scripts/run.sh"]
