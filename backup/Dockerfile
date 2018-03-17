FROM alpine:latest

ARG SOURCE_MIRROR=
ENV SOURCE_MIRROR ${SOURCE_MIRROR}
RUN if [ ${SOURCE_MIRROR} ]; then \
    sed -i "s/dl-cdn.alpinelinux.org/${SOURCE_MIRROR}/" /etc/apk/repositories \    
;fi

RUN apk update \
    && apk upgrade \
    && apk add -f --no-cache bash \
        mysql-client \
        python \
        py-pip \
        tzdata \
    && pip install coscmd

ARG TZ=PRC
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY start.sh /start.sh
COPY backup.sh /usr/bin/backup
RUN chmod +x /start.sh /usr/bin/backup

ARG COS_ACCESS_ID
ARG COS_SECRET_KEY
ARG COS_APP_ID
ARG COS_BUCKET
ARG COS_REGION
RUN coscmd config -a ${COS_ACCESS_ID} -s ${COS_SECRET_KEY} -u ${COS_APP_ID} -b ${COS_BUCKET} -r ${COS_REGION}

RUN rm -rf /var/cache/apk/*

HEALTHCHECK --interval=5s --timeout=3s \
    CMD ps aux | grep '[c]rond' || exit 1

VOLUME ["/backup"]

ENTRYPOINT ["/start.sh"]
