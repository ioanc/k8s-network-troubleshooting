# Description: This script will allow you to "ssh" into a node in a AKS cluster, regardless of the OS
# Dependencies: kubectl, jq
# Author: ioan corcodel
# Version: 0.6.0
# Limitations: This script is only tested on AKS clusters
# Compatibility: This script was only tested on Ubuntu 20.04 using bash and zsh
# Usage: source ssh-node.function
#        ssh-node <node-name>
# Url: https://learn.microsoft.com/en-us/azure/aks/use-windows-hpc#limitations
#
# With kubectl v1.30 you can use the following command to access the AKS /K8S node with full rights on Linux
# kubectl debug node/<node-name> -it --image=<image-name> --profile=sysadmin
# https://github.com/kubernetes/kubernetes/pull/119200

function ssh-node(){
  if [ -z $1 ]; then
    echo "Please provide a node name"
    return
  else
    NODE=$1
    OS=$(kubectl get node $NODE -o=jsonpath="{.metadata.labels.kubernetes\.io/os}")
    case "$OS" in
      windows)
        echo "Windows"
        echo $NODE
        IMAGE='mcr.microsoft.com/oss/kubernetes/windows-host-process-containers-base-image:v1.0.0'
        podjson='
        {
          "apiVersion": "v1",
          "kind": "Pod",
          "metadata": {
            "labels": {
              "pod": "hpc"
            },
            "name": "debug-node-NODE",
            "namespace": "kube-system"
          },
          "spec": {
            "securityContext": {
              "windowsOptions": {
                "hostProcess": true,
                "runAsUserName": "NT AUTHORITYSYSTEM"
              }
            },
            "hostNetwork": true,
            "containers": [
              {
                "name": "hpc",
                "image": "IMAGE",
                "command": [
                  "powershell.exe",
                  "-Command",
                  "Start-Sleep 2147483"
                ],
                "imagePullPolicy": "IfNotPresent"
              }
            ],
            "nodeSelector": {
              "kubernetes.io/os": "windows",
              "kubernetes.io/hostname": "NODE"
            },
            "tolerations": [
              {"operator": "Exists"}
            ]
          }
        }
        '
        echo $podjson | sed -e "s|NODE|${NODE}|g" -e "s|IMAGE|${IMAGE}|g" -e 's|AUTHORITYSYSTEM|AUTHORITY\\\\SYSTEM|g' | kubectl apply -f -
        kubectl wait --for=condition=ready pod debug-node-$NODE -n kube-system 2>1 > /dev/null
        kubectl exec -it -n kube-system debug-node-$NODE -- powershell ; kubectl delete pod debug-node-$NODE -n kube-system
      ;;
      *)
        echo "Linux"
        echo $NODE
        IMAGE='mcr.microsoft.com/mirror/docker/library/busybox:1.35'
          kubectl -n kube-system run debug-node-$NODE --restart=Never -it --rm --image overriden --overrides '{"spec": {"hostPID": true,"hostNetwork": true, "nodeSelector": { "kubernetes.io/hostname": "'${NODE:?}'"}, "tolerations": [{"operator": "Exists"}],"containers": [{"name": "nsenter", "image": "'${IMAGE:?}'","command": ["sh","-xc","nsenter -m -u -i -n -p -r -w -t 1 -- bash"], "stdin": true, "tty": true, "securityContext": {"privileged": true }}] } }'
      ;;
    esac
  fi
}
