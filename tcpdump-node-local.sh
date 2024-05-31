# Run a tcpdump for $TIMEOUT seconds creating a new file every $CHUNk seconds on an AKS $NODE and save the file on the root folder of node with the name $NODE-%M.pcap

NODE="aks-1213-NODE_NAME"
CHUNK="60"
TIMEOUT="300"
kubectl debug node/$NODE --image mcr.microsoft.com/mirror/docker/library/busybox:1.35 -- sh -xc "chroot /host timeout $TIMEOUT tcpdump -Z root -i any -G $CHUNK -w $NODE-%M.pcap 'tcp[tcpflags] & (tcp-syn) == (tcp-syn)' ; sleep inf"
