#!/usr/bin/env fish


# vars
set ypos "40"
set dir "$HOME/.covers"
set file "$dir/cover.png"
set source (mpc -f '%file%' | head -1)



# checks
if test (pidof spotify)
	set title (sps current | sed "s/.* - //")
    set artist (sps current | sed "s/ - .*//")
    set album (sps album)
else
	set title (mpc current -f "%title%")
    set artist (mpc current -f "%artist%" | sed "s/;.*//")
    set album (mpc current -f "%album%")
end

if test -z "$album"
	set saved "$dir/$artist - $title.png"
else
	set saved "$dir/$artist - $album.png"
end



# exec
if test -f "$saved"
    set file "$saved"
else
    if test -z (pidof spotify)
    	ffmpeg -loglevel "0" \
    	       -y \
    	       -i "$HOME/Music/$source" \
    	       -vf scale="-200:200" \
    	       "$file"
    else
        #
    end

	if test "$status" -eq "0"
    	cp "$file" "$saved"
	    rm "$file"
	else
	    notify-send "looking for a cover with glyr"

	    glyrc cover --album "$album" \
					--artist "$artist" \
					--title "$title" \
					--write "$file"

	    convert "$file" \
				-resize "200x200" \
				-set colorspace Gray \
				-separate \
				-average \
				-negate \
				"$file" > /dev/null 2>&1

	    cp "$file" "$saved"
	    rm "$file"
	end
end



if test -f "$saved"
    popup "$saved" "20" >/dev/null 2>&1 &
    sleep ".02"
	n30f -t "popup-arrow" \
		 -x "50" \
		 -y "40" \
	 	 -c "pkill -f 'n30f -t popup-image' && pkill -f 'n30f -t popup-background' && pkill -f 'n30f -t popup-arrow'" \
		 "/usr/scripts/popup/img/arrow.png"
else
    notify-send "cover not found"
    exit "1"
end

