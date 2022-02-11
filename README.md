# Docker Subversion Server with svn:// protocol

This Docker Subversion Server offers access via svn protocoll.

This Docker container is intended to run on **Synology DSM 7.0**, as a replacement for the SVN server package (dropped by Synology). However, it can be used on other servers as well. (maybe with small adaptions.)

---

- [Docker Subversion Server with svn:// protocol](#docker-subversion-server-with-svn-protocol)
  - [SVN Access Methods](#svn-access-methods)
  - [Quick start for Synology DSM 7.0 users](#quick-start-for-synology-dsm-70-users)
    - [Preconditions](#preconditions)
    - [Build and Run the container](#build-and-run-the-container)
    - [SVN copy existing repository](#svn-copy-existing-repository)
    - [SVN create new repository](#svn-create-new-repository)
    - [SVN access control](#svn-access-control)
    - [SVN checkout](#svn-checkout)
    - [Relocation of your working copy](#relocation-of-your-working-copy)
  - [Docker configurations](#docker-configurations)
    - [Volumes](#volumes)
    - [Ports](#ports)
    - [Environment Variables](#environment-variables)
  - [Image Components](#image-components)
    - [Ubuntu 21.10](#ubuntu-2110)
    - [Tini-Init process](#tini-init-process)
    - [SVN server](#svn-server)
    - [Cron](#cron)
    - [Entrypoint-Script](#entrypoint-script)
  - [Docker build (force cache invalidation)](#docker-build-force-cache-invalidation)
  - [Links](#links)

---

## SVN Access Methods

Generally a svn repository can be accessed via different protocolls:

- http:// or https:// webdav access via apache
- **svn:// protocoll**
- svn+ssh:// access method

Since **each protocoll uses different authentication methods** it is hard to combine different access protocols/methods.

See: <https://svnbook.red-bean.com/en/1.7/svn.serverconfig.choosing.html>

---

## Quick start for Synology DSM 7.0 users

Quick start instructions for users not interested in details.

### Preconditions

Following is assumed:

- You run Synology DSM 7.0 on your NAS (can be tested with 6.2 before update)
- Docker package is installed
- SVN repos are stored in `/volume1/svn/`
- Optional: Git server package is installed (for cloning from github)

### Build and Run the container

To run the svn server, first ssh into your NAS and execute:

```bash
cd /volume1/svn/
git clone https://github.com/MarkusH1975/svnserver.svn.mh.git
cd svnserver.svn.mh/
sudo ./start.sh
```

### SVN copy existing repository

**Create a Backup!** Copy your existing SVN-Repositories into the folder `./volume/svnrepo/`.

```bash
sudo cp -Rv /volume1/svn/myRepo1 /volume1/svn/svnserver.svn.mh/volume/svnrepo/
sudo chmod 777 -Rv /volume1/svn/svnserver.svn.mh/volume/svnrepo/
```

If you used already the svn:// protocol (DSM6.2 package) your old username and password is still stored in the repository. (See [SVN access control](#svn-access-control))

### SVN create new repository

```bash
sudo docker exec svnserver.svn svnadmin create /volume/svnrepo/myRepo1
cd /volume1/svn/svnserver.svn.mh/volume/svnrepo/
ls
    myRepo1
```

### SVN access control

To configure the ACL via svn:// protocol, go to your repository's subfolder conf.

```bash
cd /volume1/svn/svnserver.svn.mh/volume/svnrepo/myRepo1/conf/
vim passwd
```

Set username and password for `myRepo1`:

```
[users]
myUsername1=MyPassword1
myUsername2=MyPassword2
```

### SVN checkout

Now you can checkout your repository with

```bash
svn co svn://serverip/myRepo1/
```

### Relocation of your working copy

If you don't want to checkout your repository again after the move to Docker, you can relocate your working copy.

- First check actual server location with `svn info`
- Relocate with `svn relocate svn://serverip/myRepo1/`
- Check again with `svn info`

---

## Docker configurations

### Volumes

| Mountpoint | Container Folder | Description |
| - | - | - |
| `./volume/svnrepo/` | `/volume/svnrepo/` | Folder for SVN repositories. |

### Ports

| Host Port | Container Port | Description |
| - | - | - |
`0.0.0.0:3690 TCP` | `3690 TCP` | svnserve port for svn:// protocol

### Environment Variables

Environment variables to control `entrypoint.sh` script. Already set by default.

| Env var | Description |
| ------- | ----------- |
| `ENABLE_SVNSERVER=true`  |  Start svnserve  |
| `ENABLE_CRON=false`   |  Start cron, not used. Set to true if you want to set up cron jobs, e.g. for creation of regular backups. |

---

## Image Components

### Ubuntu 21.10

Was chosen as the latest Ubuntu release.

### Tini-Init process

Tini is added to have a valid init process, running as PID1. Read more information on the project page. <https://github.com/krallin/tini>.
Tini init process together with the provided entrypoint-script, is able to **run multiple services**, including graceful shutdown. It can be used as a template for other docker projects. If you attach to the container, the entrypoint-script offers a micro CLI. Type `help` for help.

### SVN server

SVN server `svnserve` is started and listen on port 3690.

### Cron

Optionally cron can be started. It is currently not used in this container and therefore by default disabled.

### Entrypoint-Script

The `entrypoint.sh` is the central bash script, which is started from tini. It can start multiple services and offers graceful shutdown of the started services. (Tini jumps in for unhandled processes.)
Furthermore the script will **initialize** the defined **volume folder**.

Since this script is the main docker process, it cannot end and needs to run in an endless loop. To make something useful, it offers a **micro command line interface**, which can be accessed via **docker attach**. Please attach to it and type `help` for more information.

---

## Docker build (force cache invalidation)

Sometimes docker build has problems to recognize that the build cache should be invalidated at some certain point. For example, if the `entrypoint.sh` script has changed, docker build is probably still using the cache and does not add the new version of the file. To force cache invalidation at a certain point the argument `CACHE_DATE` is used. Have a look at the Dockerfile and `start.sh`, how it is used.

---

## Links

This project was inspired by different Github projects and other sources, see some links below.

<https://github.com/krallin/tini>
<https://github.com/phusion/baseimage-docker>
<https://github.com/elleFlorio/svn-docker>
<https://github.com/smezger/svn-server-ubuntu>
<https://github.com/jocor87/docker-svn-ifsvnadmin>
<https://github.com/MarvAmBass/docker-subversion>
<https://github.com/ZevenFang/docker-svn-ifsvnadmin>
<https://github.com/garethflowers/docker-svn-server>

<https://github.com/mfreiholz/iF.SVNAdmin>

<https://kb.synology.com/en-sg/DSM/tutorial/How_to_launch_an_SVN_server_based_on_Docker_on_your_Synology_NAS>
<https://goinbigdata.com/docker-run-vs-cmd-vs-entrypoint/>
<https://docs.docker.com/config/containers/multi-service_container/>
<https://github.com/docker-library/official-images#init>
<https://www.cyberciti.biz/faq/howto-regenerate-openssh-host-keys/>
<https://svnbook.red-bean.com/en/1.7/svn.serverconfig.choosing.html>

<https://serverfault.com/questions/156470/testing-for-a-script-that-is-waiting-on-stdin>
<https://stackoverflow.com/a/42599638>
<https://stackoverflow.com/a/39150040>
<https://stackoverflow.com/q/70637123>

<https://serverfault.com/questions/23644/how-to-use-linux-username-and-password-with-subversion>

<https://stackoverflow.com/a/69081169>