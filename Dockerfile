FROM alpine:latest

RUN apk add --no-cache squid

COPY squid.conf /etc/squid/squid.conf

USER squid

EXPOSE 3128

CMD ["sh", "-c", "set -eu; umask 077; printf '%s\\n' \"${SQUID_PSSWRD:?SQUID_PSSWRD is required}\" > /tmp/squid-passwd; exec squid -N -f /etc/squid/squid.conf"]
