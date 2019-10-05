#!/bin/bash
# spotdl --write-to /links/Musik/unsorted/Spotify/yello.txt -b https://open.spotify.com/album/3uaQtaEy2pcGvX7EePzM0F?si=0NJlNfCvTvet_1O33dpNnw
# spotdl -f /links/Musik/unsorted/Spotify_dl/ -ff {artist}/{track_number}_{track_name} -l /links/Stefan-local/Musik/Spotify_dl/yello.txt  
LIST_FILE=/tmp/spotdl-pl.txt
spotdl --write-to ${LIST_FILE} -p ${1}
spotdl -ff singles/{artist}_{track_name} -l ${LIST_FILE}
rm ${LIST_FILE}
