FROM evilbeaver/onescript:dev

WORKDIR /app

COPY ./packagedef .

COPY bot.ospx .
RUN opm install opm && opm install -f bot.ospx

COPY ./src ./src
COPY ./main.os .
COPY ./oscript.cfg.example ./oscript.cfg

CMD ["grafana2telegramm-bot"]
