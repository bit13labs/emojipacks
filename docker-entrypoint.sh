#!/usr/bin/env bash
set -e;

__error() {
	RED='\e[0;31m';
	NC='\e[0m';
	(>&2 echo -e "${RED}${1}${NC}");
	exit 9;
}
__warning() {
	YELLOW='\e[0;33m';
	NC='\e[0m';
	(>&2 echo -e "${YELLOW}${1}${NC}");
}
__info() {
	NC='\e[0m';
	(>&2 echo -e "${NC}${1}${NC}");
}


PACKS_PATH="${SLACK_PACKS_PATH:-"./packs"}";
# FILE_PATTERN="*.yaml";

[[ -z "${SLACK_SUBDOMAIN// }" ]] && __error "Environment variable 'SLACK_SUBDOMAIN' missing or empty.";
[[ -z "${SLACK_USER_EMAIL// }" ]] && __error "Environment variable 'SLACK_USER_EMAIL' missing or empty.";
[[ -z "${SLACK_USER_PASSWORD// }" ]] && __error "Environment variable 'SLACK_USER_PASSWORD' missing or empty.";
[[ -z "${PACKS_PATH// }" ]] && __error "Environment variable 'SLACK_PACKS_PATH' missing or empty.";


for file in $PACKS_PATH/twitch-*.yaml; do
	if [ -f "$file" ]; then
		(>&2 echo "Processing $file...");
		/emojipacks/bin/emojipacks -s "$SLACK_SUBDOMAIN" -e "$SLACK_USER_EMAIL" -p "$SLACK_USER_PASSWORD" -y "$file";
	else
		(>&2 echo "$file not found");
	fi
done

bash /emojipacks/twitch/build.sh;

PACKS_PATH="/emojipacks/twitch/packs";
for file in ${PACKS_PATH}/twitch-*.yaml; do
	if [ -f "$file" ]; then
		(>&2 echo "Processing $file...");
		/emojipacks/bin/emojipacks -s "$SLACK_SUBDOMAIN" -e "$SLACK_USER_EMAIL" -p "$SLACK_USER_PASSWORD" -y "$file";
	else
		(>&2 echo "$file not found");
	fi
done
rm -rf /emojipacks/twitch/packs

unset PACKS_PATH;
