#!/usr/bin/env bash
set -e;
# .[] | "  - name: \(.code)\n    src: https://static-cdn.jtvnw.net/emoticons/v1/\(.id)/3.0"

(>&2 echo "Downloading Global Emotes data cache...");
items="$(curl -sL https://twitchemotes.com/api_cache/v3/global.json | jq -c -r '.[] | "{ \"name\": \"\(.code)\", \"src\": \"https://static-cdn.jtvnw.net/emoticons/v1/\(.id)/3.0\" }," | ascii_downcase')";
base_dir=$(dirname "$0");
WORKDIR="${WORKSPACE:-"$(pwd)"}";
twitch_file="${base_dir}/twitch-global";

packs_dir="${base_dir}/packs";
(>&2 echo "Packs directory: ${packs_dir}...");

mkdir -p "${packs_dir}";
echo "{" > "${twitch_file}.json";
echo "\"title\": \"twitch-global\"," >> "${twitch_file}.json";
echo "\"emojis\": [" >> "${twitch_file}.json";
(>&2 echo "Processing emotes...");
for i in $items; do
  echo -e "$i" >> "${twitch_file}.json";
done
echo -e "{}]\n}" >> "${twitch_file}.json";
(>&2 echo "Converting output to yaml...");

$(npm bin)/json2yaml "${twitch_file}.json" > "${twitch_file}.yaml";
rm "${twitch_file}.json";
sed -i 's|- {}||g' "${twitch_file}.yaml";
mv "${twitch_file}.yaml" "${packs_dir}/$(basename "${twitch_file}.yaml")";
cat "${packs_dir}/$(basename "${twitch_file}.yaml")";

# THIS TAKES A REALLY LONG TIME BECAUSE THIS FILE IS SO LARGE
# (>&2 echo "Downloading Subscriber Emotes data cache...");
# subscriber_file="${WORKDIR}/${base_dir}/subscriber.json";
# channels_file="${WORKDIR}/${base_dir}/channels";
# curl -L https://twitchemotes.com/api_cache/v3/subscriber.json > "${subscriber_file}";
# $(npm bin)/yaml2json "${channels_file}.yaml" > "${channels_file}.json";
# # .[] | select(.channel_name == "lirik") | .emotes[] | "{ \"name\": \"\(.code)\", \"src\": \"https://static-cdn.jtvnw.net/emoticons/v1/\(.id)/3.0\" },"
# channels=$(jq -r '.channels[]' < "${channels_file}.json");
# for c in $channels; do
# 	(>&2 echo "Processing emotes for '$c'...");
# 	(>&2 echo "These take a while...");
# 	items=$(jq -r -c '.[] | select(.channel_name == "'$c'") | .emotes[] | "{ \"name\": \"\(.code)\", \"src\": \"https://static-cdn.jtvnw.net/emoticons/v1/\(.id)/3.0\" },"');
# 	streamer_file="${WORKDIR}/${base_dir}/twitch-$c";
# 	(>&2 echo "Processing...");

# 	for i in $items; do
# 		(>&2 echo -n ".");
# 		echo -e "$i" >> "${streamer_file}.json";
# 	done
# 	(>&2 echo "");

# 	$(npm bin)/json2yaml "${streamer_file}.json" > "${streamer_file}.yaml";
# 	rm "${streamer_file}.json";
# 	sed -i 's|- {}||g' "${streamer_file}.yaml";
# 	mv "${streamer_file}.yaml" "${packs_dir}/$(basename "${streamer_file}.yaml")";
# 	unset streamer_file;
# done
# rm "${channels_file}.json";

unset packs_dir;
unset items;
unset base_dir;
unset WORKDIR;
unset twitch_file;
unset subscriber_file;
unset channels_file;
unset channels;
