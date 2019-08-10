FROM jrottenberg/ffmpeg:4.1-alpine
RUN apk add --no-cache bash
RUN apk add --no-cache cpulimit
WORKDIR /usr/src/ffmpeg-watch
COPY crontab /etc/crontabs/root
VOLUME [ "/watch", "/output", "/storage"]
COPY run.sh .
ENTRYPOINT [ "crond" ]
CMD ["-f", "-d", "8"]
