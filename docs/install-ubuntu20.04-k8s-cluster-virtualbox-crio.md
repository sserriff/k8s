# Install nodes (master/worker) using bash script
```bash
curl -sSl https://raw.githubusercontent.com/sserriff/k8s/main/install-k8s-node-ubuntu-CRI-O-virtualbox.sh | bash
```
# On master only !!!

for apiserver-advertise-address use your control-plane IP address or some internal IP if exists:
```bash
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.250
```

```bash           
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```
## store your join token and run it on all worker nodes
```yaml
---------------
kubeadm join 192.168.2.250:6443 --token ntgqbu.r24rakaybbhuehccuh \
        --discovery-token-ca-cert-hash sha256:8ce4bf0d4ce34119ef5a11111111111111111111111111111111
----------------
```

# Deploy Calico plugin (on master only)

## Using script
if your netvork adapter is enp0s3 you can use this command directly and skip next **Manual** step 
```bash
kubectl apply -f https://raw.githubusercontent.com/sserriff/k8s/main/calico.yaml
```

## Manually - only if "using script is not the option"

do not use official link: [https://docs.projectcalico.org/manifests/calico.yaml](https://docs.projectcalico.org/manifests/calico.yaml)
because it is not valid any more
use my copy instead:

```bash
curl -LO https://raw.githubusercontent.com/sserriff/k8s/main/calico.yaml
```
edit calico.yaml and add 2 lines on a proper place:
```yaml
containers:
        # Runs calico-node container on each Kubernetes node. This
        # container programs network policy and routes on each
        # host.
        - name: calico-node
          image: docker.io/calico/node:v3.20.0
          envFrom:
          - configMapRef:
              # Allow KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT to be overridden for eBPF mode.
              name: kubernetes-services-endpoint
              optional: true
          env:
            - name: IP_AUTODETECTION_METHOD      
              value: interface=enp0s3            ## change this line according to your network adapter
```

```bash
kubectl apply -f calico.yaml
```
