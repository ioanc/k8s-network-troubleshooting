# Accessing AKS node with full rights
# This is using two variables:
#
# IMAGE : the container image used to start the pod on the AKS node
# NODE : the AKS / K8s node name
#
# With kubectl v1.30 you can use the following command to access the AKS /K8S node with full rights on Linux
# kubectl debug node/<node-name> -it --image=<image-name> --profile=sysadmin
# https://github.com/kubernetes/kubernetes/pull/119200

IMAGE='mcr.microsoft.com/mirror/docker/library/busybox:1.35'
NODE="aks-nodepool1-21777443-vmss000005"

# works with AKS node images Ubuntu 22.04+ and Azure Linux
kubectl run debug-node-$NODE --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "'${NODE:?}'"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "'${IMAGE:?}'","command": ["sh","-xc","nsenter -m -u -i -n -p -r -w -t 1 -- bash"], "stdin": true, "tty": true, "securityContext": {"privileged": true }}] } }'


IMAGE='mcr.microsoft.com/cbl-mariner/base/core:2.0'
NODE="aks-nodepool1-21777443-vmss000005"
# works with ubuntu - 18.04
kubectl run debug-node-$NODE --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "'${NODE:?}'"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "'${IMAGE:?}'","command": ["sh","-xc","tdnf install util-linux -y -q; nsenter -m -u -i -n -p -C -r -w --target=1 -- bash"], "stdin": true, "tty": true, "securityContext": { "privileged": true }}] } }'
