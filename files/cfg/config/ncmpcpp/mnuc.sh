#!/bin/bash

MUSIC_DIR=$HOME/Music

DARKEN=50
GEOMETRY=80x80+50+50
IM_ARGS=(-limit memory 32mb -limit map 64mb)
COVER_METADATA_DIR=/tmp/covers

function reset_background {
	# is there any better way?
	printf "\e]20;;100x100+1000+1000\a"
}

{
	album="$(mpc --format %album% current)"
	album=$(echo $album | sed -E 's/ /\\ /')

	file="$(mpc --format %file% current)"

	tmp_file=$(basename "$file")
	tmp_file=$(echo $tmp_file | sed -E 's/ /\\ /')
	tmp_file_b=$(echo $tmp_file | base64)

	album_dir="${file%/*}"
	[[ -z "$album_dir" ]] && exit 1
	album_dir="$MUSIC_DIR/$album_dir"
	# album_dir="$(echo $album_dir | sed -E 's/ /\\ /')"

	mkdir $COVER_METADATA_DIR 2>/dev/null

	result="$COVER_METADATA_DIR/$tmp_file_b.jpg"

	if [ ! -f "$result" ]; then
		ffmpeg -i "$MUSIC_DIR/$file" "$result" &>/dev/null
		if [ ! -f "$result" ]; then
			covers=$(find "$album_dir" -maxdepth 1 -type f -iregex ".*/*.\(jpe?g\|png\)" -printf "%kKB %p\n" | sort -nr | cut -d " " -f2- | head -n 1)
		else
			covers=$result
		fi
	else
		covers=$result
	fi

	hexfile="$covers.hex"
	hexfile=$(echo $hexfile | base64)
	hexfile=$COVER_METADATA_DIR/$hexfile

	if [[ -f "$hexfile" ]]; then
		bghex=$(cat "$hexfile")
		reset_background
		printf "\e]11;rgb:${bghex}\a"
		printf "\e]708;rgb:${bghex}\a"
		printf "\e]20;${covers};${GEOMETRY}:op=keep-aspect\a"
		exit 0
	fi

	src="$(echo -n "$covers" | head -n1)"
	darkenimg="$COVER_METADATA_DIR/darken.jpg"
	if [[ -n "$src" ]]; then
		light="$((100 - $DARKEN))"
		convert "${IM_ARGS[@]}" "$src" -fill "gray${light}" +level ${light}%,${light}% \
			+matte "$darkenimg"
		composite "${IM_ARGS[@]}" "$darkenimg" -compose Multiply "$src" "$covers"
		if [[ -f "$covers" ]]; then
			bgcolor=$(convert "${IM_ARGS[@]}" "$covers" -scale 1x1 -format \
				'%[fx:int(255*r+.5)] %[fx:int(255*g+.5)] %[fx:int(255*b+.5)]' info:-)
			for c in $bgcolor; do
				bghex=$bghex/$(printf %02x $c)
			done
			bghex=${bghex:1}
			echo $bghex >"$hexfile"

			reset_background
			printf "\e]11;rgb:${bghex}\a"
			printf "\e]708;rgb:${bghex}\a"
			printf "\e]20;${covers};${GEOMETRY}:op=keep-aspect\a"
		else
			reset_background
		fi
	else
		reset_background
	fi
} &
