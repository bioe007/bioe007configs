# #!/bin/bash

RCLONE_PATH="/home/akira/clean_rclone"
RCLONE_OPTS="-P -v --log-file=/var/log/rclone/rclone.txt --skip-links"
SOURCES=(austin common documents gaming_data library media postgres software)
# --dry-run
for src in ${SOURCES[@]} ; do
    docker run --volume ${RCLONE_PATH}:/config/rclone \
        --volume /var/log/rclone:/var/log/rclone \
        --volume /mnt/pool0/${src}:/data \
        -it rclone/rclone sync /data/ aws-xertia:xertia-backup-media/${src} ${RCLONE_OPTS} 
done

