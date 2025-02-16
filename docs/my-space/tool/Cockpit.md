## [cockpit](https://github.com/cockpit-project/cockpit/) a webbase tool for manage server

### Build-in feature

* cockpit-storaged for view and manage disk
* cockpit-networkmanager view manage network
* cockpit-packagekit do update system
* cockpit-machines create and run virtual machine

### Third party

* ZFS Manager manage zfs

### [Install cockpit](https://cockpit-project.org/running.html#debian)

```
sudo su -
. /etc/os-release
echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > \
    /etc/apt/sources.list.d/backports.list
apt update
apt install -t ${VERSION_CODENAME}-backports cockpit
# next time update also need to add '-t ${VERSION_CODENAME}-backports'
```

### [Install Cockpit ZFS Manager For Debian](https://github.com/45Drives/cockpit-zfs-manager/blob/master/guides/Ubuntu20.04.md)

```
sudo su -
wget -qO - http://images.45drives.com/repo/keys/aptpubkey.asc | apt-key add -
$ curl -o /etc/apt/sources.list.d/45drives.list http://images.45drives.com/repo/debian/45drives.list
apt update
apt install cockpit-zfs-manager
systemctl restart cockpit
```
