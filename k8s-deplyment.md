# Examples

## 1. run deplyment (with 3 replicas)
```bash
kubectl create deployment mycv --image=fsabol/mycv:final  --replicas=3
```

### 1.1 store command above to yaml file without running it
```bash
kubectl create deployment mycv --image=fsabol/mycv:final  --replicas=3 -o yaml --dry-run=client > deplyment.yaml
```

### 1.2 create deplyment using configuration yaml file
```bash
kubectl create -f deplyment.yaml
```

## 2. expose NodePort 80
```bash
kubectl expose deployment mycv --type NodePort --port 80 --name mycv-svc
```

# other usefull commands

## 1. run webserver service on ubuntu (eq. httpd on centos)
```bash
sudo apt-get-update && sudo apt-get install apache2
sudo systemctl enable apache2.service
sudo systemctl start apache2.service
```

## 2. create user and add to specific group
* task:
  * Create local user instructor within group devops
  * user: instructor
  * uid: 666
  * password: Passw0rd
  * group: devops
  * gid: 666
* solution:
```bash
getent group | grep devops
groupadd -g 666 devops
useradd instructor -u 666 -g 666 -m -s /bin/bash
passwd instructor
```
## 3. volume groups stuff
```bash
# create phisical volume on HDD
pvcreate /dev/nvme1n1

# create volume group data
vgcreate data /dev/nvme1n1

# check volume groups
vgs

# create logical volume name=doker size=500MB
lvcreate -n docker -L 500M data

# check logical volumes
lvs

# create filesystem on docker logical volume
mkfs.ext4 /dev/mapper/data-docker

# create dir for mounting point
mkdir /var/lib/docker

# just helpful print for exho
cat /etc/fstab
lsblk -f

# add mount point do /etc/fstab
echo "UUID=a9a59a28-ad91-42bb-a68e-515882bf5011 /var/lib/docker  ext4  defaults  0 0" >> /etc/fstab

# check fstab
cat /etc/fstab

# mount new filesystem
mount -a
```
