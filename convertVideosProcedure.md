# Convert Videos Procedure

The tools expect the files to be in '/links/FamilienVideos-ssd/temp/input'
Then use the tools in following order.

## Merge Videos into one file
Identify all videos you want to merge (create one file aut of several) and put them into input Folder
```
concatVideo.sh -o mkv
```

## Process files in a folder
If you still have several files for one day copy all files of this day into input folder, then call
```
convertVideosFolder.sh -i 1
```
This will prepend Numbers to filename 

Finally copy remaingin files to pinput folder and call
```
convertVideosFolder.sh
```



