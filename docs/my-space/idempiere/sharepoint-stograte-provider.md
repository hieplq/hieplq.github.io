By default, Idempiere stores files in a database. It has built-in Storage Providers to use the file system. But what if you want to use remote storage like Google Drive, OneDrive, SharePoint, etc.?

Implementing a new Storage Provider for each remote storage is one option. This guide will help you use Rclone and the built-in file system Storage Providers to utilize remote storage.

In this guide, we will use SharePoint-365 as an example for remote storage. You can find out more about the storage supported by Rclone [here](https://github.com/rclone/rclone?tab=readme-ov-file#storage-providers).

## Install the Latest Version of Rclone

To install Rclone, run the following commands:

```bash
curl https://rclone.org/install.sh | sudo bash
rclone version
```

## Configure Rclone

For configuring Rclone, I referenced these two documents: [link 1](https://rclone.org/onedrive/#excessive-throttling-or-blocked-on-sharepoint) and [link 2](https://rclone.org/remote_setup/).

To start the configuration, run:

```bash
rclone config
```

You will see the following options:

```
e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
```

### Step 1: Create a New Remote

Choose `n` to create a new remote.

```bash
Enter name for new remote.
name> sharepoint365
```

### Step 2: Naming Your Configuration

You will be prompted to choose the type of storage to configure. Choose the number corresponding to "Microsoft OneDrive" (in my case, it's 36).

```bash
Option Storage.
Type of storage to configure.
Choose a number from below, or type in your own value.
...
36 / Microsoft OneDrive
   \ (onedrive)
...
Storage>36
```

### Step 3: Client ID

For the `client_id`, `client_secret`, `region`, and `tenant` options, you can leave them empty for default.

```bash
Option client_id.
OAuth Client Id.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_id> 
```

### Step 4: Client Secret

```bash
Option client_secret.
OAuth Client Secret.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_secret> 
```

### Step 5: Region

```bash
Option region.
Choose national cloud region for OneDrive.
Choose a number from below, or type in your own value of type string.
Press Enter for the default (global).
 1 / Microsoft Cloud Global
   \ (global)
 2 / Microsoft Cloud for US Government
   \ (us)
 3 / Microsoft Cloud Germany (deprecated - try global region first).
   \ (de)
 4 / Azure and Office 365 operated by Vnet Group in China
   \ (cn)
region> 
```

### Step 6: Tenant

```bash
Option tenant.
ID of the service principal's tenant. Also called its directory ID.
Set this if using
- Client Credential flow
Enter a value. Press Enter to leave empty.
tenant>
```

### Step 7: Advanced Config

```bash
Edit advanced config?
y) Yes
n) No (default)
y/n>
```

Choose `n` to keep the default settings.

### Step 8: Web Browser Authentication

```bash
Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.

y) Yes (default)
n) No
y/n>N
```

Input `N` because I am configuring this for a server through SSH.

### Step 9: Config Token

For this step, you will need to run the following command on a machine that has a web browser:

```bash
rclone authorize "onedrive"
```

end of authenticate process on browse, token generate on terminal like bellow

![1747027983362](image/sharepoint-stograte-provider/1747027983362.png)


Then paste the result back into the terminal of server.
{"access_token":
....

"expiry":"2025-05-12T13:46:25.57477855+07:00"}

### Step 10: Config Type

```bash
Option config_type.
Type of connection
Choose a number from below, or type in an existing value of type string.
Press Enter for the default (onedrive).
 1 / OneDrive Personal or Business
   \ (onedrive)
 2 / Root Sharepoint site
   \ (sharepoint)
   / Sharepoint site name or URL
 3 | E.g. mysite or https://contoso.sharepoint.com/sites/mysite
   \ (url)
 4 / Search for a Sharepoint site
   \ (search)
 5 / Type in driveID (advanced)
   \ (driveid)
 6 / Type in SiteID (advanced)
   \ (siteid)
   / Sharepoint server-relative path (advanced)
 7 | E.g. /teams/hr
   \ (path)
config_type>4
```

I chose `4` to search for the site on SharePoint, which I had already prepared.

![1747028875036](image/sharepoint-stograte-provider/1747028875036.png)

### Step 11: Config Search Term

```bash
Option config_search_term.
Search term
Enter a value.
config_search_term> ERPRepository
```

Input the site name of SharePoint for the search.

### Step 12: Config Site

```bash
Option config_site.
Select the Site you want to use
Choose a number from below, or type in your own value of type string.
Press Enter for the default ([mydomain].sharepoint.com,xxx).
 1 / ERP Repository (https://[mydomain].sharepoint.com/sites/ERPRepository)
   \ ([mydomain].sharepoint.com,xxx)
config_site> 1
```

Verify the site name to choose the correct site (here I choose `1`).

### Step 13: Config Drive ID

```bash
Option config_driveid.
Select drive you want to use
Choose a number from below, or type in your own value of type string.
Press Enter for the default (document identify).
 1 / Documents (documentLibrary)
   \ (document identify)
config_driveid>1
```

Choose the folder to sync (here I choose `Documents`; the next step will add a subfolder to separate the prod and dev environments).

### Step 14: Drive Confirmation

```bash
Drive OK?

Found drive "root" of type "documentLibrary"
URL: https://[my domain].sharepoint.com/sites/ERPRepository/Shared%20Documents

y) Yes (default)
n) No
y/n> y
```

Confirm the chosen folder.

### Step 15: Save Configuration

```bash
Configuration complete.
Options:
- type: onedrive
- token: {"access_token":""}
- drive_id: document identify
- drive_type: documentLibrary
Keep this "sharepoint365" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d> y
```

Yes, save the configuration.

```bash
Current remotes:

Name                 Type
====                 ====
sharepoint365        onedrive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q>q
```

Input `q` to quit the configuration.

The configuration is stored at `~/.config/rclone/rclone.conf`; you can refine the configuration by editing this file.

## Configure Rclone to Mount Remote Folder Locally and Run on System Start Without User Login

```bash
sudo su -
export idempiereUser=idempiere
export mountPoint=/mnt/sharepoint365
mkdir -p $mountPoint
chown $idempiereUser:$idempiereUser $mountPoint
```

1. Create a mount point and set the correct permissions for the Idempiere user.

```bash
export serviceFilePath=/etc/systemd/system/rclone-mount.service
export remoteMount=sharepoint365
# configuration name
export configPath=/home/$idempiereUser/.config/rclone/rclone.conf

cat << EOF >> $serviceFilePath
[Unit]
Description=Mount Rclone Remote
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount $remoteMount: $mountPoint \
  --config=$configPath \
  --vfs-cache-mode writes \
  --allow-other \
  --umask 002 \
  --daemon-timeout 5m
Restart=on-failure
User=$idempiereUser
Group=$idempiereUser

[Install]
WantedBy=default.target

EOF

# for --allow-other option
sed -i -r "s|^#user_allow_other|user_allow_other|" /etc/fuse.conf
cat /etc/fuse.conf | grep user_allow_other

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable rclone-mount.service
systemctl start rclone-mount.service

export devMountPoint=$mountPoint/dev
mkdir -p $devMountPoint
chown $idempiereUser:$idempiereUser $devMountPoint


# on server mode for security don't use option --allow-other
# The --allow-other option in rclone mount (and other FUSE-based mounts) allows users other than the one who ran the command to access the mounted filesystem

```

2. Create a service for auto-run.
3. Configure the Storage Provider in Idempiere (this can be done at the Tenant or System level).

![1747031721907](image/sharepoint-stograte-provider/1747031721907.png)

![1747031787302](image/sharepoint-stograte-provider/1747031787302.png)

4. Run "Migrate Storage Provider" to move the current files (from the database) to the new Storage Provider.

![1747031856651](image/sharepoint-stograte-provider/1747031856651.png)
