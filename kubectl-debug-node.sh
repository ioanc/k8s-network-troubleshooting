# This is using two variables:
#
# IMAGE : the container image used to start the pod on the AKS node
# NODE : the AKS node name

IMAGE="ubuntu:22.04"
NODE="aks-nodepool1-21777443-vmss000005"

# nodes based on Ubuntu 22.04 disk image
kubectl run debug-node-$NODE --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "'${NODE:?}'"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "'${IMAGE:?}'","command": ["nsenter", "--all", "--target=1", "--", "su", "-"], "stdin": true, "tty": true, "securityContext": { "privileged": true }}] } }'

# nodes based on Ubuntu 18.04 disk image - deprecated since AKS 1.25
# kubectl run debug-node-$NODE --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "'${NODE:?}'"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "'${IMAGE:?}'","command": ["nsenter", "-m", "-u", "-i", "-n", "-p", "-C", "-r", "-w", "--target=1", "--", "su", "-"], "stdin": true, "tty": true, "securityContext": { "privileged": true }}] } }'
