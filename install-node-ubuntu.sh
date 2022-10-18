#!/bin/bash
# This Script is used for automated installation of K8S stuff on Ubuntu.

# Variables
ver=1.25.0-00

## Disable SWAP
swapoff -a
cp /etc/fstab /etc/fstab_orig
sed -e '/swap/ s/^#*/#/' -i /etc/fstab

## containerd
apt-get install -y containerd
# Generate Default Config
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
# Start Service
systemctl enable containerd --now

# Enable Modules for containerd
modprobe overlay
modprobe br_netfilter
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

## Sysctl parameters
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
echo '1' > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo '1' > /proc/sys/net/ipv4/ip_forward

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

## Kubernetes
# Add K8S repository
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Install Dependencies 
apt-get -y install apt-transport-https ca-certificates curl
curl -fsSLo /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
# Install K8S
apt update
apt-get -y install kubelet=${ver} kubeadm=${ver} kubectl=${ver}

# Lock installed versions
apt-mark hold kubeadm kubelet kubectl

# Enable Kubelet Service
systemctl enable kubelet

# Extra packages
