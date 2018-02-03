#!/usr/bin/env bash

# .[] | "  - name: \(.code)\n    src: https://static-cdn.jtvnw.net/emoticons/v1/\(.id)/3.0"

items="$(curl -sL https://twitchemotes.com/api_cache/v3/global.json | jq --compact-output --raw-output '.[] | "  - name: \(.code)\n    src: https://static-cdn.jtvnw.net/emoticons/v1/\(.id)/3.0"')";
base_dir=$(dirname "$0");
WORKDIR="${WORKSPACE:-"$(pwd)"}";

echo "title: twitch-global" > "${WORKDIR}/${base_dir}/twitch-global.yaml";
echo "emojis:" >> "${WORKDIR}/${base_dir}/twitch-global.yaml";
for i in $items; do
  echo -e "$i" >> "${WORKDIR}/${base_dir}/twitch-global.yaml";
done
