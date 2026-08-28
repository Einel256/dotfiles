function jplay --description "Play m3u8 stream with mouse-enabled terminal UI"
    if test (count $argv) -eq 0
        echo "Usage: jplay <m3u8_url>"
        return 1
    end

    mpv --no-video \
        --terminal=yes \
        --input-terminal=yes \
        --input-cursor=yes \
        --term-osd-bar=yes \
        --force-seekable=yes \
        --demuxer-max-bytes=500MiB \
        --http-header-fields="Referer: https://japaneseasmr.com/" \
        $argv[1]
end
