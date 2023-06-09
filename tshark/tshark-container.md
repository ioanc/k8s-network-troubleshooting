## tshark on alpine container image for network debugging in kubernetes

### Variables:

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

### podman command
 
	running the container with --privileged and env variable

	Example: podman run -d --privileged --env JFILTER="frame ip tcp udp" localhost/alpine-tshark:010

### filtering log output using jq from docker / podman container output

	jq filter where ip addreses and tcp analysis rrt are not null

	Example: podman logs -f 9a199679905cb44 | jq -c '.layers| select (.ip.ip_ip_host != null and .tcp.tcp_tcp_analysis_ack_rtt != null) | [.frame.frame_frame_time, .ip.ip_ip_host, .ip.ip_ip_id, .tcp.tcp_tcp_port, .tcp.tcp_tcp_analysis_ack_rtt, .tcp.tcp_tcp_flags_str]'

### filtering log output using jq from pod container output

	jq filter where ip addreses and tcp analysis rrt are not null

	Example: kubectl logs -f {pod-name} -c tshark | grep "^{" | jq -c '.layers| select (.ip.ip_ip_host != null and .tcp.tcp_tcp_analysis_ack_rtt != null) | [ .frame.frame_frame_time, .ip.ip_ip_host, .ip.ip_ip_id, .tcp.tcp_tcp_port]'
	

### TODO: add variable(s) to limit time or number of packet captured
