Scale the specific DamonSet to 0
```shell
DAEMONSET="ama-logs"
kubectl patch -n kube-system daemonset $DAEMONSET -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'
```

Scale the specific DamonSet back to initial replicas 
```shell
DAEMONSET="ama-logs"
kubectl patch -n kube-system daemonset $DAEMONSET --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
```
