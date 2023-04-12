# Container image, running tshark on alpine:3.17.3

## Variables:

+ $FILTER
	tcpdump filter - not mandatory

+ $JFILTER 
	Protocol top level filter used for ek|json|jsonraw|pdml output file types.

	The protocol’s parent node and all child nodes are included. 

	Lower-level protocols must be explicitly specified in the filter.

	Example: tshark -J "tcp http"

+ $jFILTER
	Protocol match filter used for ek|json|jsonraw|pdml output file types.

	Only the protocol’s parent node is included.

	Child nodes are only included if explicitly specified in the filter.

	Example: tshark -j "ip ip.flags http"

## podman command 
	running the container with --privileged and env variable

	Example: podman run -d --privileged --env JFILTER="ip tcp udp" localhost/alpine-tshark:006

## jq filtering the log output

	jq filter where ip addreses and tcp analysis rrt are not null
	
	Example: podman logs -f 9a199679905cb44 | jq -c '.layers| select (.ip.ip_ip_host != null and .tcp.tcp_tcp_analysis_ack_rtt != null) | [.ip.ip_ip_host, .ip.ip_ip_id, .tcp.tcp_tcp_port, .tcp.tcp_tcp_analysis_ack_rtt, .tcp.tcp_tcp_flags_str]'

## TODO: add variable(s) to limit time or number of packet captured
