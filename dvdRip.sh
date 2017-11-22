i=1
DVDTracks=( 
"An der schönen blauen Donau (MTV Unplugged)" 
)
#\
#"Bergbauernbuam (MTV Unplugged)" \
#"Home Sweet Home (MTV Unplugged)" \
#"Daham bin i nur bei dir (MTV Unplugged)" \
#"Dirndl lieben (MTV Unplugged)" \
#"Es wär' an der Zeit (MTV Unplugged)" \
#"Edelweiss (MTV Unplugged)" \
#"You're Just Bein' You (MTV Unplugged)" \
#"In deine Arm zu liegn (MTV Unplugged)" \
#"Hulapalu (MTV Unplugged) [feat. 257ers]" \
#"So liab hob i di (MTV Unplugged)" \
#"In diesem Moment (MTV Unplugged) [feat. Gregor Meyle]" \
#"Für mich bist du schön (MTV Unplugged)" \
#"Der Himmel (MTV Unplugged)" \
#"Sie (MTV Unplugged) [feat. Max Giesinger]" \
#"Ohne di (MTV Unplugged)" \
#"You Can't Always Get What You Want (MTV Unplugged)" \
#"Vergiss die Heimat nie (MTV Unplugged)" \
#"A Meinung haben (MTV Unplugged) [feat. Xavier Naidoo]" \
#"12 Ender Hirsch - I sing a Liad für di - Es wird alles wieder gut (MTV Unplugged)" \
#"VolksRock'n'Roller (MTV Unplugged)" \
#"Amoi seg' ma uns wieder (MTV Unplugged) [feat. Anna Netrebko]" \
#"Encore (MTV Unplugged)" \
#)

IFS=""
for file in ${DVDTracks[@]}; do
  echo "transcoding $file"
  transcode -i /dev/sr0 \
            -x dvd \
            -T 1,$((i++)),1 \
            -b 192,1,5,1 \
            -a 0 \
            -y null,lame \
            -m $file
done
