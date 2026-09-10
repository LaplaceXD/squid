FROM alpine:latest

RUN apk add --no-cache squid apache2-utils

RUN touch /etc/squid/passwd \
    && chown squid:squid /etc/squid/passwd \
    && chmod 600 /etc/squid/passwd

COPY squid.conf /etc/squid/squid.conf

COPY entrypoint.sh .

USER squid

EXPOSE 3128

ENTRYPOINT ["./entrypoint.sh"]

CMD ["squid", "-N", "-f", "/etc/squid/squid.conf"]
