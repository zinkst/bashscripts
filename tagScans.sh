#!/usr/bin/env bash
find . -wholename "*ProfiDiaScan/*.jpg" -exec exiftool -P -overwrite_original -make="Reflecta" -model="DigitDia 4000" -FileSource="Film Scanner" {} \;
find . -wholename "*FlachbettDiaScan/*.jpg" -exec exiftool -P -overwrite_original -make="Hewlett Packard" -model="Scanjet 5370c" -FileSource="Film Scanner" {} \;
#find . -type d -name "2000W" -exec  ls -l  {} \;
#find . -type d -name "2000X" -exec echo {} \;

