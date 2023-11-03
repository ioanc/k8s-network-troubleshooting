```shell
kubectl -n kube-system patch daemonset ama-logs -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'

kubectl -n kube-system patch daemonset ama-logs --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
```
