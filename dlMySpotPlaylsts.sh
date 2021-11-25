#!/bin/bash
# changed to use current version of spotdl
# see https://github.com/spotDL/spotify-downloader
# 
# deprecated
# uses old spotdl see https://github.com/ritiek/spotify-downloader/issues
# pip install git+https://github.com/ritiek/spotify-downloader.git
# pip install --upgrade pytube

WRKDIR="/links/Musik/Spotify-Playlist-mp3s"

PLName[1]="incorrect"
PLUrl[1]="https://open.spotify.com/playlist/0ebhEOjfDxvvEQ7PwNGQpY?si=0Q8jKqg3SMK4zy1vxL0VdA&utm_source=native-share-menu"
PLName[2]="HardRock"
PLUrl[2]="https://open.spotify.com/playlist/4THAeCcJAQE3QCqYnL6yl1?si=H9YsBgIKQTW7dTAhAROZiQ&utm_source=native-share-menu"
PLName[3]="Neues"
PLUrl[3]="https://open.spotify.com/playlist/5mNjLwK6C1kwmTbFeQfUug?si=nPvZ8j9cRly5kALm_JVNow&utm_source=native-share-menu"
PLName[4]="ProgressiveRock"
PLUrl[4]="https://open.spotify.com/playlist/27ipBHvUaTg5CHDu8uSzay?si=gpblQEm-Ts-VbfGbda9gAw&utm_source=native-share-menu"
PLName[5]="AggressiveMetal"
PLUrl[5]="https://open.spotify.com/playlist/5kh9zXE2T8MSBkkmxBJ8Kg?si=srrz5I_mT_WlzcBsV-b48Q&utm_source=native-share-menu"
PLName[6]="Balladen"
PLUrl[6]="https://open.spotify.com/playlist/05e1TJ3D0aXIzomAPIa6rW?si=csEnUXZ1QB6dAiy2q0wy0w&utm_source=native-share-menu"
PLName[7]="Deutsch"
PLUrl[7]="https://open.spotify.com/playlist/26qqmTQEnnMF7NtASGPgv4?si=vHS-wAZiQCGazgvCYl1nYQ&utm_source=native-share-menu"
PLName[8]="Deutsch"
PLUrl[8]="https://open.spotify.com/playlist/26qqmTQEnnMF7NtASGPgv4?si=vHS-wAZiQCGazgvCYl1nYQ&utm_source=native-share-menu"
PLName[9]="Indie"
PLUrl[9]="https://open.spotify.com/playlist/5A7KL1ZrqxqRhbGgmJa0uz?si=dBehOiUSTPKWpAlFy94n5Q&utm_source=native-share-menu"
PLName[10]="Party"
PLUrl[10]="https://open.spotify.com/playlist/3QtYL74xWB7BXTobCmpG0M?si=XmrJS_wOQqymTGINzYOqrg&utm_source=native-share-menu"
PLName[11]="Pop"
PLUrl[11]="https://open.spotify.com/playlist/3CkrwsVsj2FaF6PepQuQpF?si=mAG8AR0pTqmBql-m0HqwwA&utm_source=native-share-menu"
PLName[12]="Rap"
PLUrl[12]="https://open.spotify.com/playlist/0udoAE0IoNWe0xaRSqoMml?si=LahlZ04gRKW-VtEgBLuA4A&utm_source=native-share-menu"
PLName[13]="Rock"
PLUrl[13]="https://open.spotify.com/playlist/0nr1BGwrfz1aque1hngsqp?si=hpZTECogS_KbfeRRYSmrsQ&utm_source=native-share-menu"
PLName[14]="Tecno"
PLUrl[14]="https://open.spotify.com/playlist/15OonYLtY1EnxANpJR3pLP?si=W-u8KHzPR7Ow6wHEdKiRvg&utm_source=native-share-menu"
PLName[15]="Disco"
PLUrl[15]="https://open.spotify.com/playlist/5mQj9waMjVXB5pPJSKUzK7?si=8c2cde8be37a47b8"

#pushd ${WRKDIR}
index="2 3 4 5 6 7 8 9 10 11 12 13 14 15"
#index="5 6"
pushd "${WRKDIR}"
for ind in $index
do
  if [ ! -d "${WRKDIR}/${PLName[ind]}" ]; then
    mkdir -p "${WRKDIR}/${PLName[ind]}"
  fi  

  ## spotdl-v2
  # spotdl --write-to ${WRKDIR}/${PLName[ind]}.lst -p ${PLUrl[ind]} 
  # spotdl -l ${WRKDIR}/${PLName[ind]}.lst --write-m3u
  # cp ${WRKDIR}/${PLName[ind]}.lst ${WRKDIR}/${PLName[ind]}.spotlst
  # spotdl -f ${WRKDIR}/${PLName[ind]}/{artist}_{track-name}.{output-ext} -l ${WRKDIR}/${PLName[ind]}.lst --overwrite skip
  # rm ${WRKDIR}/${PLName[ind]}.lst
  ###
  pushd "${WRKDIR}/${PLName[ind]}"
  echo "Extracting to dir: $(pwd)"
  cmd="spotdl ${PLUrl[ind]} --path-template '{artist}_{title}.{ext}' --output-format mp3 --download-threads 8"
  echo "$cmd"
  spotdl ${PLUrl[ind]} --path-template '{artist}_{title}.{ext}' --output-format mp3 --download-threads 8
  popd
done
popd
reset
