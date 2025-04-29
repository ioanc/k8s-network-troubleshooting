# Manual steps to check PSI CPU on Kubernetes node on pods & containers

### References

    https://facebookmicrosites.github.io/psi/docs/overview
    https://github.com/kubernetes/enhancements/tree/master/keps/sig-node/4205-psi-metric
    https://github.com/kubernetes/enhancements/issues/5062
    https://docs.kernel.org/accounting/psi.html#pressure-interface

### Start

Get the nodes name

`
kubectl get nodes
`

    NAME                                STATUS   ROLES   AGE    VERSION
    aks-agentpool-20482960-vmss000015   Ready    agent   140m   v1.28.10
    aks-agentpool-20482960-vmss000016   Ready    agent   140m   v1.28.10
    aks-agentpool-20482960-vmss000017   Ready    agent   140m   v1.28.10

Add node name where to check PSI, as variable  
In my example the node name is aks-agentpool-20482960-vmss000016

`
NODE="aks-agentpool-20482960-vmss000016"
`

Create a debug pod on the specific node to read the PSI

`
kubectl debug node/$NODE --image mcr.microsoft.com/azurelinux/busybox:1.36 -- sleep 3600
`

    Creating debugging pod node-debugger-aks-agentpool-20482960-vmss000016-spdvs with container debugger on node aks-agentpool-20482960-vmss000016.

Exec into the node-debugger pod created above and identify the top 11 kubepods.slice with highest 'some CPU presure' on avg300  
The first line is the presure at the  /host/sys/fs/cgroup/kubepods.slice/kubepods-<qos_class>.slice/ level  
Starting with the second line we get the PSI for pods and its containsers  

`
kubectl exec node-debugger-aks-agentpool-20482960-vmss000016-spdvs -- sh -c 'find /host/sys/fs/cgroup/kubepods.slice/* -name "cpu.pressure" -exec echo -n {} \; -exec grep some {} \; | grep -A1 -e "cri-containerd" | sed -E "s/=/ /g" | sort -n -rk7 | head -n11'
`

    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/cpu.pressuresome avg10 73.20 avg60 73.52 avg300 73.71 total 9004921086
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod2b019d47_7460_48dc_ad55_65b96f27a21b.slice/cpu.pressuresome avg10 69.05 avg60 69.33 avg300 69.36 total 4889708912
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod2b019d47_7460_48dc_ad55_65b96f27a21b.slice/cri-containerd-c0e8beabdcbfdd647290c8e1396c5c5f6f67f4ba76aac0affbda977644e06809.scope/cpu.pressuresome avg10 49.14 avg60 49.20 avg300 49.21 total 3483277389
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod2b019d47_7460_48dc_ad55_65b96f27a21b.slice/cri-containerd-79d87bd73afecb69a8ee4781bf157743b0584628a96d55296d89ebffee4b09ad.scope/cpu.pressuresome avg10 38.77 avg60 38.80 avg300 38.83 total 2749590864
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod44d3c1c5_90bf_45b6_a901_cee849fbf210.slice/cpu.pressuresome avg10 5.10 avg60 5.40 avg300 5.95 total 829672259
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod44d3c1c5_90bf_45b6_a901_cee849fbf210.slice/cri-containerd-55e0490413c036c947e6cdefcbf13ece376612bd767400060830453197ad8081.scope/cpu.pressuresome avg10 4.94 avg60 5.36 avg300 5.93 total 825606263
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod21c23964_bcaf_442e_a1c5_901ffe50a23f.slice/cpu.pressuresome avg10 3.09 avg60 3.29 avg300 3.15 total 485868766
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod21c23964_bcaf_442e_a1c5_901ffe50a23f.slice/cri-containerd-0879965178ab665c70d40539374704f71ffe1392a6015998ced98d758c4028fa.scope/cpu.pressuresome avg10 3.01 avg60 3.24 avg300 3.10 total 481025674
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod44b4c5db_511e_4cab_96d3_45e52cb2c959.slice/cpu.pressuresome avg10 0.94 avg60 1.39 avg300 1.56 total 305378436
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod44b4c5db_511e_4cab_96d3_45e52cb2c959.slice/cri-containerd-0510eed44ed0f517699b87cfe191a1d6483adae48071b59a6cc0eddee80d8c45.scope/cpu.pressuresome avg10 0.87 avg60 1.36 avg300 1.57 total 304265639
    /host/sys/fs/cgroup/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-podaf1ea02b_057d_4013_a2a1_1f3825546b32.slice/cri-containerd-ef5a5ee798ba3974c83a625b45c8f798a791fb7648637e151d0755cc8cad37c0.scope/cpu.pressuresome avg10 1.13 avg60 1.23 avg300 1.45 total 320202127

Find pod(s) with the highest CPU pressure based on container id, from above  
Output will show the pod namespace, name, uid and container(s) id  

`
CONTAINER_ID=c0e8beabdcbfdd647290c8e1396c5c5f6f67f4ba76aac0affbda977644e06809
`

`
kubectl get pods -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.metadata.uid}{"\t"}{.status.containerStatuses[*].containerID}{"\n"}{end}' | grep $CONTAINER_ID
`

    default stress-ng       containerd://c0e8beabdcbfdd647290c8e1396c5c5f6f67f4ba76aac0affbda977644e06809 containerd://79d87bd73afecb69a8ee4781bf157743b0584628a96d55296d89ebffee4b09ad
