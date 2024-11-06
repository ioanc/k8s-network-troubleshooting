# Run a tcpdump for $TIMEOUT seconds creating a new file every $CHUNk seconds on an AKS $NODE and save the file on the root folder of node with the name $NODE-%I-%M.pcap
# Capture files will be rotted every 60 minutes, using the file name $NODE-%M.pcap
# Capture files will be rotted every 12 hours, using the file name $NODE_%I-%M.pcap ; check 'man strftime'
# We capture only the fist 256 bites of the packet; -s 256
# tcpdump will capture only IP address 1.2.3.4 ; Change the IP address in the filter for the POD IP address running on the node, that you need to capture the traffic.
# This is just an example and will need to be customised for specific troubleshooting sceanrio! 

# replace with the actual noe name
NODE="aks-1213-NODE_NAME"
# repace with the number of seconds you want tcpdump to stop automaticaly; we use here 3600s -> 1 hour.
TIMEOUT="3600"

# create a new file every 300 seconds
CHUNK="300"
kubectl debug node/$NODE --image mcr.microsoft.com/mirror/docker/library/busybox:1.35 -- sh -xc "chroot /host timeout $TIMEOUT tcpdump -Z root -i any -s 256 -G $CHUNK -w $NODE_%I-%M.pcap 'host 1.2.3.4' ; sleep inf"
