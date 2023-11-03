```shell
kubectl patch -n kube-system daemonset ama-logs -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'

kubectl patch -n kube-system daemonset ama-logs --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
```
