alias yd="yt-dlp"
alias ydv="yt-dlp -f 'bv*[height<=1080][ext=mp4]+ba/b' --no-playlist"
alias ydp="yt-dlp -f 'bv*[height<=1080][ext=mp4]+ba/b' -o '%(playlist_index)s [%(playlist_id)s]  - %(title)s.%(ext)s'"
alias yda="yt-dlp -f '[ext=mp4]+ba/b' --extract-audio --no-playlist"
