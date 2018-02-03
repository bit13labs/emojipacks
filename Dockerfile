FROM node:9-alpine

ARG PROJECT_NAME="emojipacks"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG APP_NAME="emojipacks"

ARG SLACK_SUBDOMAIN
ARG SLACK_USER_EMAIL
ARG SLACK_USER_PASSWORD
ARG SLACK_PACKS_PATH="/emojipacks/packs"

ENV SLACK_SUBDOMAIN="${SLACK_SUBDOMAIN}"
ENV SLACK_USER_EMAIL="${SLACK_USER_EMAIL}"
ENV SLACK_USER_PASSWORD="${SLACK_USER_PASSWORD}"
ENV SLACK_PACKS_PATH="${SLACK_PACKS_PATH}"

LABEL \
  LABEL="${PROJECT_NAME}-v${BUILD_VERSION}" \
  BUILD_VERSION="${BUILD_VERSION}"

RUN test -n "$SLACK_SUBDOMAIN"
RUN test -n "$SLACK_USER_EMAIL"
RUN test -n "$SLACK_USER_PASSWORD"

RUN \
  mkdir -p /emojipacks/packs && \
  mkdir -p /emojipacks/bin && \
  mkdir -p /emojipacks/lib

COPY . /emojipacks/

WORKDIR /emojipacks

RUN \
  apk add --no-cache bash && \
  rm -rf /var/cache/apk/* && \
  chmod +x /emojipacks/docker-entrypoint.sh && \
  npm version "${BUILD_VERSION}" --git-tag-version && \
  npm install --production;

CMD [ \
  "SLACK_PACKS_PATH=${SLACK_PACKS_PATH}", \
  "SLACK_USER_PASSWORD=${SLACK_USER_PASSWORD}", \
  "SLACK_USER_EMAIL=${SLACK_USER_EMAIL}", \
  "SLACK_SUBDOMAIN=${SLACK_SUBDOMAIN}" \
]
ENTRYPOINT [ "/emojipacks/docker-entrypoint.sh" ]
