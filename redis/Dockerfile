FROM redis:latest

VOLUME /data
VOLUME /usr/local/etc

ARG TZ=UTC
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 6379

CMD ["redis-server", "/usr/local/etc/redis.conf"]
