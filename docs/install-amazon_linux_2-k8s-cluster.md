## Po prihlaseni zmenit hostname kazdej na master1/worker1/workwer2

* Ako root:
  
  ```bash 
  hostnamectl set-hostname master1
  ```
	
## Na vsetkych 3 vm spustit script od peta alebo rucne pospustat vsetky commandy:

* Ako root:
	
  ```bash 
  sudo su - 
  ```
* Vytvorit subor script s kodom nizsie

	```bash 
  vi scrtipt.sh
  ```
		
* Nakopirovat do neho cely script nizsie
* Zmenit prava suboru aby bol spustitelny:

  ```bash 
  chmod 777 script.sh
  ```
* Spustit script a cakat :)

  ```bash 
  ./script.sh
  ```

## script.sh
```bash
#!/bin/bash
# This Script is used for automated installation of K8S stuff.
 
# Variables
ver=1.23.0
 
## Disable SELINUX
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
 
## Disable SWAP
swapoff -a
cp /etc/fstab /etc/fstab_orig
sed -e '/swap/ s/^#*/#/' -i /etc/fstab
 
## containerd
yum -y install containerd
# Generate Default Config
containerd config default > /etc/containerd/config.toml
# Start Service
systemctl enable containerd --now
 
# Enable Module
modprobe br_netfilter
modprobe overlay
cat <<EOF | tee /etc/modules-load.d/custom.conf
br_netfilter
overlay
EOF
 
## Sysctl parameters
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
echo '1' > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo '1' > /proc/sys/net/ipv4/ip_forward
 
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
 
## Kubernetes
# Add K8S repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
         https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
 
# Install Kubernetes
yum install -y kubelet-${ver} kubeadm-${ver} kubectl-${ver}
 
# Lock installed versions
yum install -y yum-plugin-versionlock
yum versionlock kubelet kubeadm kubectl 
 
# Enable Kubelet Service
systemctl enable kubelet
 
# Extra packages
yum -y install iproute-tc
```
