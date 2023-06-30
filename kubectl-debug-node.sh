# works with ubuntu 22.04
kubectl run debug-node --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "aks-nodepool1-27749346-vmss00000g"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "mcr.microsoft.com/oss/nginx/nginx:1.21.6","command": ["nsenter", "--all", "--target=1", "--", "su", "-"], "stdin": true, "tty": true, "securityContext": { "privileged": true }}] } }'

# for older Ubuntu nodes - 18.04
kubectl run debug-node-aks-agentpool-21180280-vmss000000 --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "aks-agentpool-21180280-vmss000000"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "mcr.microsoft.com/oss/nginx/nginx:1.21.6","command": ["nsenter", "-m", "-u", "-i", "-n", "-p", "-C", "-r", "-w", "--target=1", "--", "su
", "-"], "stdin": true, "tty": true, "securityContext": { "privileged": true }}] } }'
