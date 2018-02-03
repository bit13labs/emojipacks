FROM node:9-alpine

ARG PROJECT_NAME="emojipacks"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG APP_NAME="emojipacks"

ARG SLACK_SUBDOMAIN
ARG SLACK_USER_EMAIL
ARG SLACK_USER_PASSWORD

LABEL \
  LABEL="${PROJECT_NAME}-v${BUILD_VERSION}" \
  BUILD_VERSION="${BUILD_VERSION}"

RUN test -n "$SLACK_SUBDOMAIN"
RUN test -n "$SLACK_USER_EMAIL"
RUN test -n "$SLACK_USER_PASSWORD"


RUN \
  mkdir -p /emojipacks/packs && \
  mkdir -p /emojipacks/bin && \
  mkdir -p /emojipacks/lib && 

COPY packs/* /emojipacks/packs/
