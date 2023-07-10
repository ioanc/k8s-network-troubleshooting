Small test go application, that can be started a cliet or server.
The need of this application came when troubleshooting a network connection issue between 2 application not ussing tcp keepalive

+ Start application as server, with default values

      ./client-server server -h
      Usage of server:
      -idle duration
            idle time duration in seconds (default 30s)
      -ip string
            listening ip address (default "0.0.0.0")
      -keepalive
            keepAlive
      -port string
            listening server port (default "12345")

+ Start application as client, with default value for port; ip address needs to be set

      ./client-server client -h
      Usage of client:
      -ip string
            remote ip address
      -port string
            remote port port (default "12345")


![180044_57900](https://github.com/ioanc/k8s-network-troubleshooting/assets/16124079/a50fbc8f-1616-422a-8898-5aa92d34b13e)


Used https://www.linode.com/docs/guides/developing-udp-and-tcp-clients-and-servers-in-go/ as source of inspiration
