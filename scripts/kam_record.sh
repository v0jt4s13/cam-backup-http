#!/bin/bash
# Ustawienia
source ../config.env
username=$KAM_USERNAME
password=$KAM_PASSWORD
VIDEO_TARGET_DIR="/var/www/html/static/videos" # Katalog do monitorowania
STREAM_TARGET_DIR="/var/www/html/hls" 
MAX_USAGE=50000000      # Maksymalne użycie przestrzeni dyskowej w kB
# Funkcja do usuwania starych plików, gdy przekroczona jest quota ;)
reduce_disk_usage_if_needed() {
    while [ $(du -s "$VIDEO_TARGET_DIR" | cut -f1) -gt $MAX_USAGE ]; do
        # Znajdź i usuń najstarszy plik
        OLDEST_FILE=$(find "$VIDEO_TARGET_DIR" -type f -printf '%T+ %p\n' | sort | head -n 1 | cut -d" " -f2-)
        echo "Usuwanie najstarszego pliku: $OLDEST_FILE"
        rm -f "$OLDEST_FILE"
        # jakaś obsługa błędu
        if [ $? -ne 0 ]; then
            echo "Błąd przy usuwaniu pliku: $OLDEST_FILE"
            exit 1
        fi
    done
}
# Pętla do działania, albo w crona można to wrzucic bo nie wiem czy nie  przymuliłoby to za bardo sprzetu ...
# W pythonie musiałem zrezygnować z takiej pętli bo mi sie wiatrak włączył ;) i laps prawie nie odleciał
# ffmpeg -i rtsp://$username:$password@192.168.0.31:554/Streaming/Channels/1 -c:v copy -c:a copy -hls_time 2 -hls_list_size 5 -hls_flags delete_segments "$STREAM_TARGET_DIR/stream.m3u8"
while true
do
    # Odpal funkcje
    reduce_disk_usage_if_needed
    # Jak rozumiem poniższa linia odpowiada za nagrywanie wideo więc nie ruszam
    ffmpeg -i rtsp://$username:$password@192.168.0.31:554 -f segment -segment_time 600 -vcodec copy -strftime 1 -map 0 -t 01:00:00 "$VIDEO_TARGET_DIR/garden.%Y%m%d-%H%M.mp4"
    # url = 'rtsp://$username:$password@192.168.0.31:554/Streaming/Channels/1'
    # ffplay -fs -window_title kam1 rtsp://$username:$password@192.168.0.31:554/Streaming/Channels/1    
    # ffmpeg -i rtsp://$username:$password@192.168.0.31:554/Streaming/Channels/1 -c:v copy -c:a aac -f hls -hls_time 2 -hls_list_size 3 -hls_flags delete_segments+append_list+omit_endlist /home/oem/PythonApps/website/stream.m3u8

done
