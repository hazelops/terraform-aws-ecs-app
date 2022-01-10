FROM python:3.7-alpine

ARG PROJECT_PATH=.
ENV \
APP_HOME=/app


RUN echo $PROJECT_PATH
WORKDIR $APP_HOME

RUN set -ex && \
    apk add --no-cache \
    python3 \
    bash \
    curl \
    tzdata \
    ca-certificates \
  && \
    ln -s /usr/bin/python3 /usr/bin/python

# Copy files and pipenv
COPY ${PROJECT_PATH}/public/index.html  ./public/index.html
COPY ${PROJECT_PATH}/app.py  ./
COPY ${PROJECT_PATH}/Pipfile* ./
COPY ${PROJECT_PATH}/nginx.conf.template ./
COPY ${PROJECT_PATH}/docker-entrypoint.sh /


RUN python3 -m pip install pipenv

RUN pipenv install --deploy --system

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000
