FROM ubuntu:xenial

RUN \
  apt-get update && \
  apt-get install -y curl bzip2

RUN curl -L -o /tmp/teamspeak.tar.bz2 https://files.teamspeak-services.com/releases/server/3.9.1/teamspeak3-server_linux_amd64-3.9.1.tar.bz2

RUN cd /tmp && tar -jxvf teamspeak.tar.bz2 && rm /tmp/teamspeak.tar.bz2

RUN mv /tmp/teamspeak3-server_linux_amd64 /ts3

ENV LD_LIBRARY_PATH /ts3

# Install minio client
RUN curl -L -o /usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x /usr/local/bin/mc

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

# Per default, the TS3 server creates a virtual voice server on port 9987 (UDP). The ServerQuery is listening on port 10011 (TCP) and file transfers will use port 30033 (TCP)
EXPOSE 9987 10011 30033
