Two small go application, client and server, that communicate with each other over TCP and do not use tcp keepalives

The tcpclient-no-keepalive need one paramater:

- IPv4 address and TCP port of the server in the format x.x.x.x:abcd

      ./tcpclient-no-keepalive 192.168.1.5:12345

The tcpserver-no-keepalive application needs 3 parameters
- IPv4 address to bind to ; can be used also 0.0.0.0
- TCP port listenening on
- timout in seconds, after it will send the actual data requested by the client
  
      ./tcpserver-no-keepalive 192.168.1.5 12345 60

![190412_44287](https://github.com/ioanc/k8s-network-troubleshooting/assets/16124079/f668577c-6913-4084-9ef5-727fc94b448b)


Used https://www.linode.com/docs/guides/developing-udp-and-tcp-clients-and-servers-in-go/ as source of inspiration
