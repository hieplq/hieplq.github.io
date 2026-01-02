lsblk

zpool create \
  -o compatibility=off \
  -o ashift=12 \
  -o autotrim=on \
  -o delegation=on \
  zfsdisk /dev/sda

# list all properties for zpool
man zpoolprops
man zfsprops

zfs set relatime=on zfsdisk
zfs set atime=off zfsdisk
zfs set compression=off zfsdisk

chown -R hieplq:hieplq /zfsdisk
chmod -R 770 /zfsdisk

zpool destroy zfsdisk
zpool labelclear -f /dev/sda

sudo zfs create zfsdisk/data
zfs set relatime=on zfsdisk/data
zfs set atime=off zfsdisk/data

zfs create zfsdisk/movies
zfs set compression=off zfsdisk/movies
zfs set atime=off zfsdisk/movies
zfs set recordsize=1M zfsdisk/movies

zfs create zfsdisk/iso
zfs set compression=off zfsdisk/iso
zfs set atime=off zfsdisk/iso
zfs set recordsize=1M zfsdisk/iso
chown -R hieplq:hieplq /zfsdisk/iso
chmod -R 770 /zfsdisk/iso

zfs create zfsdisk/ebooks
zfs set compression=lz4 zfsdisk/ebooks
zfs set atime=off zfsdisk/ebooks
zfs set recordsize=128K zfsdisk/ebooks
chown -R hieplq:hieplq /zfsdisk/ebooks
chmod -R 770 /zfsdisk/ebooks

sudo zfs set acltype=posix zfsdisk
# set right for current files
sudo setfacl -R -m u:hieplq:rwx /zfsdisk
# set right for new files
sudo setfacl -d -m u:hieplq:rwx /zfsdisk

sudo zpool import zfsdisk


sudo zpool list
sudo zfs list

sudo zfs create -o mountpoint=/mnt/data/1Dev zfsdisk/1Dev

zfs send -v -R dblab_pool@move1 | mbuffer -q -s 128k -m 512M > /mnt/data/data.zfs

mbuffer -q -s 128k -m 512M < /mnt/data/data.zfs | zfs receive -v -F -d zfsdisk

/mnt/dataold/postgresql-data-dir/docker

sudo apt install mbuffer

zfs send -v -R dblab_pool@move | mbuffer -q -s 128k -m 512M | zfs receive -F zfsdisk

// on usb
# record size set per dataset not pool
zfs get recordsize dblab_pool 
-s 128k: matches ZFS record size
-m 512M: memory buffer to absorb slow reads

128K is the default (optimal for general use)
For large files (VMs, backups), it may be 1M
Smaller sizes (e.g. 16K, 8K) are better for databases like PostgreSQL

# encryption (per dataset not per pool)
-w: raw send; sends encrypted blocks directly

zfs get encryption dblab_pool

# compression
zfs get compression dblab_pool # value per dataset not per pool

# all
zfs get recordsize,compression,encryption dblab_pool
// on disk
zfs set compression=zstd zfs

zfs get recordsize zfs
zfs get recordsize dblab_pool