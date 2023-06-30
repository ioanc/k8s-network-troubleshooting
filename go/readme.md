Two small go application, client and server, that communicate with each other over TCP and do not use tcp keepalives

The tcpclient-no-keepalive need one paramater:

- IPv4 address and TCP port of the server in the format x.x.x.x:abcd

      ./tcpclient-no-keepalive 192.168.1.5:12345

The tcpserver-no-keepalive application needs 3 parameters
- IPv4 address to bind to on the Linux system
- TCP port listenening on
- timout in seconds, after it will send the actual data requested by the client
  
      ./tcpserver-no-keepalive 192.168.1.5 12345 60

Used https://www.linode.com/docs/guides/developing-udp-and-tcp-clients-and-servers-in-go/ as source of inspiration
