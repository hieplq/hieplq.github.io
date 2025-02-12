
```bash
# https://wiki.debian.org/ZFS#Snapshot_Utilities
codename=$(lsb_release -cs);echo "deb http://deb.debian.org/debian $codename-backports main contrib non-free"|sudo tee -a /etc/apt/sources.list && sudo apt update

sudo apt install linux-headers-amd64
sudo apt-get install -y zfsutils-linux
sudo apt install -t stable-backports zfsutils-linux

# zfs common command
sudo zpool status -v
lsblk -o NAME,UUID,SIZE,MOUNTPOINT
df -hT
zpool list

# profile core12
export dbPort=5434
export cluterName=core12
export pgVer=15
export dbPortPoolStart=6040
export dbPortPoolEnd=6049
export enginePort=2345
export engineUIPort=2346

# profile ntier
export dbPort=5437
export cluterName=ntier
export pgVer=15
export dbPortPoolStart=6070
export dbPortPoolEnd=6079
export enginePort=2375
export engineUIPort=2376

export dblabHome=~/.dblab/engine/$cluterName
export dblabConf=$dblabHome/configs

## change database setting to help docker can connect to and do replicate
# ip addr show
export dockerIp=172.17.0.5
export dockerHostIp=172.17.0.1
sudo sed -i "1s|^|host all adempiere $dockerIp/16 scram-sha-256\nhost replication all $dockerIp/16 scram-sha-256\n|" /etc/postgresql/$pgVer/$cluterName/pg_hba.conf
sudo sed -i -r "s|^(port = ${dbPort}.*)|listen_addresses = 'localhost,$dockerHostIp'\n\1\n|g" /etc/postgresql/$pgVer/$cluterName/postgresql.conf
sudo pg_ctlcluster $pgVer $cluterName restart


export dblabVer=3.5.0
export DBLAB_DISK="/dev/sda2"

export rootMountPoint=/var/lib/dblab

export mountNameDefault=dblab_pool
export mountPointDefault=dblab_pool

sudo zpool create -f \
  -O compression=on \
  -O atime=off \
  -O recordsize=128k \
  -O logbias=throughput \
  -m $rootMountPoint/$mountPointDefault \
  $mountNameDefault \
  "${DBLAB_DISK}"

export cluterMountPoint=zfs$cluterName
export cluterMountName=$mountNameDefault/$cluterName
sudo zfs create -o mountpoint=$rootMountPoint/$cluterMountPoint $cluterMountName

# zfs destroy -R $cluterMountName

mkdir -p $dblabConf
curl -fsSL https://gitlab.com/postgres-ai/database-lab/-/raw/v$dblabVer/engine/configs/config.example.physical_generic.yml \
  --output $dblabConf/server.yml

sed -i -r 's|^  verificationToken: "secret_token"|  verificationToken: "edlhYHOgBPkr4ix1qP3YvQMytfK2JSxH"|' $dblabConf/server.yml
sed -i -r 's|^          PGUSER: "postgres"|          PGUSER: "adempiere"|' $dblabConf/server.yml
sed -i -r 's|^          PGPASSWORD: "postgres"|          PGPASSWORD: "adempiere"|' $dblabConf/server.yml
sed -i -r 's|^          PGHOST: "source.hostname"|          PGHOST: "172.17.0.1"|' $dblabConf/server.yml
sed -i -r "s|^          PGPORT: 5432|          PGPORT: $dbPort|" $dblabConf/server.yml
sed -i -r 's|^  dockerImage: "postgresai/extended-postgres:15-0.4.1"|  dockerImage: "postgresai/extended-postgres:15-0.5.1"|' $dblabConf/server.yml
sed -i -r "s|^  dockerImage: \"postgresai/ce-ui:latest\"|  dockerImage: \"postgresai/ce-ui:$dblabVer\"|" $dblabConf/server.yml
sed -i -r 's|^  maxIdleMinutes: 120|  maxIdleMinutes: 0|' $dblabConf/server.yml
sed -i -r 's|^  keepUserPasswords: false|  keepUserPasswords: true|' $dblabConf/server.yml
sed -i -r "s|^    from: 6000|    from: $dbPortPoolStart|" $dblabConf/server.yml
sed -i -r "s|^    to: 6099|    to: $dbPortPoolEnd|" $dblabConf/server.yml
sed -i -r "s|^  dataSubDir: data|  dataSubDir: data$cluterName|" $dblabConf/server.yml
sed -i -r "s|^(          command: \"pg_basebackup -X stream -D /var/lib/dblab)/dblab_pool/data|\1/$cluterMountPoint/data$cluterName|" $dblabConf/server.yml

sed -i -r "s|^  port: 2345|  port: $enginePort|" $dblabConf/server.yml
sed -i -r "s|^  port: 2346|  port: $engineUIPort|" $dblabConf/server.yml
sed -i -r "s|^  clonesMountSubDir: clones|  clonesMountSubDir: clones$cluterName|" $dblabConf/server.yml
sed -i -r "s|^  socketSubDir: sockets|  socketSubDir: sockets$cluterName|" $dblabConf/server.yml
sed -i -r "s|^  observerSubDir: observer|  observerSubDir: observer$cluterName|" $dblabConf/server.yml
sed -i -r "s|^  selectedPool: \"\"|  selectedPool: \"$cluterMountPoint\"|" $dblabConf/server.yml


export dockerDblabName=dblab_server_$cluterName
sudo docker run \
  --name $dockerDblabName \
  --label dblab_control \
  --privileged \
  --publish 127.0.0.1:$enginePort:$enginePort \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume $rootMountPoint:/var/lib/dblab/:rshared \
  --volume ~/.dblab/engine/$cluterName/configs:/home/dblab/configs \
  --volume ~/.dblab/engine/$cluterName/meta:/home/dblab/meta \
  --volume ~/.dblab/engine/$cluterName/logs:/home/dblab/logs \
  --volume /sys/kernel/debug:/sys/kernel/debug:rw \
  --volume /lib/modules:/lib/modules:ro \
  --volume /proc:/host_proc:ro \
  --env DOCKER_API_VERSION=1.39 \
  --detach \
  --restart on-failure \
  postgresai/dblab-server:$dblabVer
```
