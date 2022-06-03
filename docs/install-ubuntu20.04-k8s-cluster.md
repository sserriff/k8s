1. Set proper Hostnames & Set DNS resolution

2. Enable Kernel Modules
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

Activate Modules:
modprobe overlay
modprobe br_netfilter

3. Set sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables    = 1
net.ipv4.ip_forward                   = 1
net.bridge.bridge-nf.call-ip6iptables = 1
EOF

Reload settings:
sysctl --system

4. Install Container runtime
apt-get update 
apt-get install -y containerd   

5. Containerd config
mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

6. Disable SWAP

7. Install needed packages
apt-install apt-transport-https curl

8. K8S Repos
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-update

9. Install K8S packages
apt-get install kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00

Disable automatic update of such packages:
apt-mark hold kubelet kubeadm kubectl


10. Initialize Cluster via kubeadm
kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.0
