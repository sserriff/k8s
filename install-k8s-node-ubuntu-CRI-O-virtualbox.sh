#!/bin/bash
# This Script is used for automated installation of K8S stuff on Ubuntu in Virtualbox using CRI-O.

# Variables
ver=1.25.0-00

## Disable SWAP
swapoff -a
cp /etc/fstab /etc/fstab_orig
sed -e '/swap/ s/^#*/#/' -i /etc/fstab

## Install CRI-O Container Runtime

# Generate Default Config
mkdir /etc/apt/keyrings
export OS=xUbuntu_22.04
export VER=1.25

# update repository and gpg keys
curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /etc/apt/keyrings/crio1.gpg
curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VER/$OS/Release.key | gpg --dearmor -o /etc/apt/keyrings/crio2.gpg
echo "deb [signed-by=/etc/apt/keyrings/crio1.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/crio1.list
echo "deb [signed-by=/etc/apt/keyrings/crio2.gpg] http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VER/$OS/ /" > /etc/apt/sources.list.d/crio2.list

# instal CRI-O
apt-get update
apt install -y cri-o cri-o-runc containernetworking-plugins

# edit /etc/crio/crio.conf
cp /etc/crio/crio.conf /etc/crio/crio.conf_orig

sudo sed -i '/^\[crio.network\]/a network_dir = "\/etc\/cni\/net.d\/"\nplugin_dirs = \[\n"\/opt\/cni\/bin\/",\n"\/usr\/lib\/cni\/",\n\]' /etc/crio/crio.conf

rm -f /etc/cni/net.d/100-crio-bridge.conf

curl -fsSLo /etc/cni/11-crio-ipv4-bridge.conf https://raw.githubusercontent.com/cri-o/cri-o/main/contrib/cni/11-crio-ipv4-bridge.conflist

# start crio service
mkdir /var/lib/crio
systemctl enable crio
service crio start

## Install kubeadm, kubelet and kubectl
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get -y install kubelet=${ver} kubeadm=${ver} kubectl=${ver}

# configure Linux kernel
modprobe br_netfilter
echo 'br_netfilter' >> /etc/modules
echo '1' > /proc/sys/net/ipv4/ip_forward

echo 'ipv4.ip_forward=1' > /etc/sysctl.d/k8s.conf
sysctl -p

# Lock installed versions
apt-mark hold kubeadm kubelet kubectl

# Enable Kubelet Service
systemctl enable kubelet
