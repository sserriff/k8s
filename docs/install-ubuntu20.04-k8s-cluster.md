# 1. Set proper Hostnames & Set DNS resolution

# 2. Enable Kernel Modules
```bash
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```

# 2.1 Activate Modules:
```bash
modprobe overlay
modprobe br_netfilter
```

# 3. Set sysctl parameters
```bash
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables    = 1
net.ipv4.ip_forward                   = 1
net.bridge.bridge-nf.call-ip6iptables = 1
EOF
```

Reload settings:
```bash
sysctl --system
```

# 4. Install Container runtime
```bash
apt-get update 
apt-get install -y containerd   
```

# 5. Containerd config
```bash
mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd
```

# 6. Disable SWAP
```bash
swapoff -a
```

# 7. Install needed packages
```bash
apt-get install apt-transport-https curl -y
```

# 8. K8S Repos
```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```
```bash
apt-get update
```

# 9. Install K8S packages
```bash
apt-get install kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00 -y
```

Disable automatic update of such packages:
```bash
apt-mark hold kubelet kubeadm kubectl
```

# 10. Initialize Cluster via kubeadm (on master only)
```bash
kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.0
```
# 11. Implement Container
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# 12. on master only
```bash
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
optional:
```bash
watch -n 1 kubectl get nodes
```
# 13. join workers (on workers only)
```bash
kubeadm join 172.31.110.125:6443 --token 1taqcj.0m76cview1jcjz5j \
        --discovery-token-ca-cert-hash sha256:4d053a4337d0cdd65db71790ef4d1a7108fc9cb299e6e5db884125bcecd1db27
```
