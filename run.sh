#!/bin/bash

while :
do

echo "$(tput setaf 1)Login to Seedbox"

login=
pass=
host=
remote_dir=/downloads/sync/
local_dir=/mnt/virtual/SeedBoxSync/sync/


touch /tmp/synctorrent.lock

echo "$(tput setaf 1)Fetching Data"

  lftp -u $login,$pass $host << EOF
  set ssl:verify-certificate false
  set ftp:ssl-allow yes
  set mirror:use-pget-n 5
  mirror -P5 -v --no-empty-dirs --Remove-source-files --log=synctorrents.log --exclude freeleech/ $remote_dir $local_dir
  quit
EOF

echo "$(tput setaf 1)Complete Sync"

echo "Lets Unrar"

find /mnt/virtual/SeedBoxSync/sync/ -name "*.rar" -exec unrar e -o+ {} /mnt/virtual/SeedBoxSync/sync/ \;

echo "Lets Convert..."

find /mnt/virtual/SeedBoxSync/sync/ -name "*.mkv" -exec /opt/sickbeard_mp4_automator/manual.py -a -i {} \;

echo "Lets Move Some Data"

#find /mnt/virtual/SeedBoxSync/sync/ -name "*.mp4" -o -name "*.avi" -exec mv -t /mnt/virtual/SeedBoxSync/completed/ {} +

rsync -avzh --info=progress2 --exclude "*.r*" /mnt/virtual/SeedBoxSync/sync/ /mnt/virtual/SeedBoxSync/completed/

echo "Lets Clean Sync Folder"
rm -r /mnt/virtual/SeedBoxSync/sync/*

echo "Sync Completed..$(tput sgr 0)"


sleep 10

#Sonarr API
curl http://localhost:8989/api/command -X POST -d '{"name": "downloadedepisodesscan"}' --header "X-Api-Key:API KEY"

#Couch API
curl http://localhost:5050/api/APIKEYHERE/renamer.scan

echo "Start 30 Min Sleep"
sleep 1800
echo "Sleep Over - Run Script"


rm /tmp/synctorrent.lock

echo ""

done
