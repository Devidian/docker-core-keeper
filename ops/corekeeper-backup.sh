#!/usr/bin/env bash
set -euo pipefail

umask 077
data_dir=/appdata/core-keeper/data
backup_dir=/appdata/core-keeper/backups/daily
world_file="$data_dir/worlds/2.world.gzip"

if [[ ! -s "$world_file" ]]; then
	echo "Core Keeper world 2 save is missing or empty: $world_file" >&2
	exit 1
fi

mkdir -p "$backup_dir"
destination="$backup_dir/$(date -u +%Y%m%dT%H%M%SZ)"
if [[ -e "$destination" ]]; then
	echo "Backup destination already exists: $destination" >&2
	exit 1
fi

temporary_dir=""
trap 'if [[ -n "$temporary_dir" ]]; then rm -rf -- "$temporary_dir"; fi' EXIT

for attempt in 1 2 3; do
	temporary_dir=$(mktemp -d "$backup_dir/.incomplete.XXXXXXXX")
	before=$(sha256sum "$world_file")
	before=${before%% *}
	cp -a "$data_dir/." "$temporary_dir/"
	after=$(sha256sum "$world_file")
	after=${after%% *}
	copied=$(sha256sum "$temporary_dir/worlds/2.world.gzip")
	copied=${copied%% *}

	if [[ "$before" == "$after" && "$after" == "$copied" ]]; then
		mv "$temporary_dir" "$destination"
		temporary_dir=""
		echo "Core Keeper backup created: $destination"
		exit 0
	fi

	rm -rf -- "$temporary_dir"
	temporary_dir=""
	sleep 2
done

echo "Core Keeper world 2 changed during each backup attempt." >&2
exit 1
