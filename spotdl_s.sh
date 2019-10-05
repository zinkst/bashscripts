#!/bin/bash
# spotdl -f /links/Musik/unsorted/Spotify/ -ff {artist}_{track_name} -s https://open.spotify.com/track/3vt3PujsPrEyPfgKnzsmbB?si=Q4_iBj55RuCaghklE6Qc0g 
# spotdl --write-to /links/Musik/unsorted/Spotify/yello.txt -b https://open.spotify.com/album/3uaQtaEy2pcGvX7EePzM0F?si=0NJlNfCvTvet_1O33dpNnw
# spotdl -f /links/Musik/unsorted/Spotify_dl/ -ff {artist}/{track_number}_{track_name} -l /links/Stefan-local/Musik/Spotify_dl/yello.txt  
spotdl -ff {artist}_{track_name} -s ${1}
