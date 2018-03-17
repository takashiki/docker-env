FROM nginx:alpine

ARG SOURCE_MIRROR=
ENV SOURCE_MIRROR ${SOURCE_MIRROR}
RUN if [ ${SOURCE_MIRROR} ]; then \
    sed -i "s/dl-cdn.alpinelinux.org/${SOURCE_MIRROR}/" /etc/apk/repositories \
;fi

RUN apk update \
    && apk upgrade \
    && apk add -f --no-cache bash openssl curl socat tzdata \
    && adduser -D -H -u 1000 -s /bin/bash www-data

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV LE_CONFIG_HOME=/acme.sh
ENV AUTO_UPGRADE=1

RUN mkdir /install_acme.sh \
    && cd /install_acme.sh \
    && curl https://get.acme.sh | sh \
    && rm -rf /install_acme.sh \
    && ln -s  /root/.acme.sh/acme.sh  /usr/local/bin/acme.sh \
    && crontab -l | grep acme.sh | sed 's#> /dev/null##' | crontab -

ADD reload /usr/bin/reload
RUN chmod +x /usr/bin/reload

RUN rm -rf /var/cache/apk/*

CMD ["crond", "-f"]

EXPOSE 80 443
