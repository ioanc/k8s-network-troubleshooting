
# works with ubuntu 22.04
NODE="node-name"
kubectl run debug-node-$NODE --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "'${NODE:?}'"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "mcr.microsoft.com/oss/nginx/nginx:1.21.6","command": ["nsenter", "--all", "--target=1", "--", "su", "-"], "stdin": true, "tty": true, "securityContext": { "privileged": true }}] } }'

# for older Ubuntu nodes - 18.04
NODE="node-name"
kubectl run debug-node-$NODE --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "'${NODE:?}'"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "mcr.microsoft.com/oss/nginx/nginx:1.21.6","command": ["nsenter", "-m", "-u", "-i", "-n", "-p", "-C", "-r", "-w", "--target=1", "--", "su", "-"], "stdin": true, "tty": true, "securityContext": { "privileged": true }}] } }'
