# Run a tcpdump for $TIMEOUT seconds creating a new file every $CHUNk seconds on an AKS $NODE and save the file on the root folder of node with the name $NODE-%M.pcap

NODE="aks-1213-NODE_NAME"
CHUNk="60"
TIMEOUT="300"
kubectl debug node/$NODE --image docker.io/alpine:3.18.2 -- sh -xc "chroot /host timeout 300 tcpdump $TIMEOUT -Z root -i any -G $CHAIN -w $NODE-%M.pcap 'tcp[tcpflags] & (tcp-syn) == (tcp-syn)' ; sleep inf"
