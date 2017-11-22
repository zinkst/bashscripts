#/bin/bash
find Gemeinsam_test/ -type f ! -perm -664 -exec chmod 664 {} \;
find . -type d -perm 755 -exec ls -ld {} \;
