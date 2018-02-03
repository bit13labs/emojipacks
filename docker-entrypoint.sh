#!/usr/bin/env bash

PACKS_PATH="${SLACK_PACKS_PATH:-"./packs"}";

[[ -z "${SLACK_SUBDOMAIN// }" ]] && __error "Environment variable 'SLACK_SUBDOMAIN' missing or empty.";
[[ -z "${SLACK_USER_EMAIL// }" ]] && __error "Environment variable 'SLACK_USER_EMAIL' missing or empty.";
[[ -z "${SLACK_USER_PASSWORD// }" ]] && __error "Environment variable 'SLACK_USER_PASSWORD' missing or empty.";
[[ -z "${PACKS_PATH// }" ]] && __error "Environment variable 'SLACK_PACKS_PATH' missing or empty.";


for file in "$SLACK_PACKS_PATH"/*.yaml; do
  echo "$file";
  ./bin/emojipacks -s "$SLACK_SUBDOMAIN" -e "$SLACK_USER_EMAIL" -p "$SLACK_USER_PASSWORD" -y "$file";
done

unset PACKS_PATH;
