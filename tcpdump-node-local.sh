# Run a tcpdump for $TIMEOUT seconds creating a new file every $CHUNk seconds on an AKS $NODE and save the file on the root folder of node with the name $NODE-%M.pcap

NODE="aks-1213-NODE_NAME"                                                                                                                                                                                                                  [10:49:25+0200]
CHUNk="60"                                                                                                                                                                                                                                 [10:49:32+0200]
TIMEOUT="300"                                                                                                                                                                                                                              [10:49:36+0200]
kubectl debug node/$NODE --image docker.io/alpine:3.18.2 -- sh -xc "chroot /host timeout 300 tcpdump $TIMEOUT -Z root -i any -G $CHAIN -w $NODE-%M.pcap 'tcp[tcpflags] & (tcp-syn) == (tcp-syn)' ; sleep inf"
