# Run a tcpdump for $TIMEOUT seconds creating a new file every $CHUNk seconds on an AKS $NODE and save the file on the root folder of node with the name $NODE-%M.pcap
# Capture files will be rotted after 60 minutes.
# Capure will be filtered IP address 1.2.3.4
# Files will be rotated after every 12h, using the file name $NODE_%I-%M.pcap - %I - strftime 

NODE="aks-1213-NODE_NAME"
CHUNK="60"
TIMEOUT="300"
kubectl debug node/$NODE --image mcr.microsoft.com/mirror/docker/library/busybox:1.35 -- sh -xc "chroot /host timeout $TIMEOUT tcpdump -Z root -i any -G $CHUNK -w $NODE_%I-%M.pcap 'host 1.2.3.4' ; sleep inf"
