#!/usr/bin/env bash

# Get the api key
key=$(cat ~/i3lock-delta/api_key)
# Get the queries
queries=$(cat ~/.config/lock_preferences | xargs)
# Construct the base url
url="https://api.unsplash.com/photos/random?client_id=$key&orientation=landscape&featured=false"

# Check if there are any queries
if [ -n "$queries" ]; then
  url="$url&query=$(shuf -n 1 ~/.config/lock_preferences)"
fi

# make API call and check if curl fails
if ! json=$(curl -s $url); then
  exit 1
fi

# Get image location from json
image_download_url=$(echo $json | jq -r ".links.download_location")
image_download_url="$image_download_url?client_id=$key"
image_url=$(curl -s $image_download_url | jq -r .url)
if [[ $? -ne 0 ]] ; then exit 1; fi

# Download image and check if curl fails
curl -s $image_url > ~/.rand_bg
if [[ $? -ne 0 ]] ; then exit 1; fi

# Write author's name to file
user_name=$(echo $json | jq -r ".user.name")
echo "$user_name" > /tmp/name_photographer
