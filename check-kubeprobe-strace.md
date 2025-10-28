Install kubectl v1.30 or newer

```shell
https://kubernetes.io/docs/tasks/tools/#kubectl
```

Attach strace to the specific binary name, coredns, to observe the behavior of kube-probe, on the node where the pod/container is running, e.g. srfb2

strace will be terminated after 60s

check the context -C8 for grep, to ensure you get the right output

```shell
kubectl -n kube-system debug node/srfb2 --profile sysadmin --image mcr.microsoft.com/azurelinux/busybox:1.36 \
-- sh -xc "chroot /host timeout 60 strace -e trace=network,read,write -tt -T -Y -y -s 150 -f -p \$(pidof -s coredns) 2>&1 | grep -C8 kube-probe ; sleep inf"
```

Check the logs of the debug pod; Use the name from the output of the above command 

```shell
kubectl logs -n kube-system node-debugger-srfb2-xxxxx
```

Example output

```log
kubectl logs -n kube-system node-debugger-srfb2-xxxxx
+ grep -C12 kube-probe
+ pidof -s coredns
+ chroot /host timeout 60 strace -e 'trace=network,read,write' -tt -T -Y -y -s 150 -f -p 2995209
[pid 2995209<coredns>] 23:20:43.004554 read(5<pipe:[94734928]>, "\0", 16) = 1 <0.000037>
[pid 2995209<coredns>] 23:20:43.249795 accept4(8<socket:[94733937]>, {sa_family=AF_INET6, sin6_port=htons(47826), sin6_flowinfo=htonl(0), inet_pton(AF_INET6, "::ffff:10.244.0.1", &sin6_addr), sin6_scope_id=0}, [112 => 28], SOCK_CLOEXEC|SOCK_NONBLOCK) = 14<socket:[254938647]> <0.000108>
[pid 2995209<coredns>] 23:20:43.250459 getsockname(14<socket:[254938647]>, {sa_family=AF_INET6, sin6_port=htons(8080), sin6_flowinfo=htonl(0), inet_pton(AF_INET6, "::ffff:10.244.0.106", &sin6_addr), sin6_scope_id=0}, [112 => 28]) = 0 <0.000062>
[pid 2995209<coredns>] 23:20:43.250756 setsockopt(14<socket:[254938647]>, SOL_TCP, TCP_NODELAY, [1], 4) = 0 <0.000130>
[pid 2995209<coredns>] 23:20:43.251012 setsockopt(14<socket:[254938647]>, SOL_SOCKET, SO_KEEPALIVE, [1], 4) = 0 <0.000071>
[pid 2995209<coredns>] 23:20:43.251206 setsockopt(14<socket:[254938647]>, SOL_TCP, TCP_KEEPINTVL, [15], 4) = 0 <0.000059>
[pid 2995209<coredns>] 23:20:43.251415 setsockopt(14<socket:[254938647]>, SOL_TCP, TCP_KEEPIDLE, [15], 4) = 0 <0.000023>
[pid 2995209<coredns>] 23:20:43.251713 accept4(8<socket:[94733937]>, 0xc00078fba8, [112], SOCK_CLOEXEC|SOCK_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable) <0.000081>
[pid 2995244<coredns>] 23:20:43.252031 read(14<socket:[254938647]>, "GET /health HTTP/1.1\r\nHost: 10.244.0.106:8080\r\nUser-Agent: kube-probe/1.32\r\nAccept: */*\r\nConnection: close\r\n\r\n", 4096) = 110 <0.000060>
[pid 2995244<coredns>] 23:20:43.252619 write(14<socket:[254938647]>, "HTTP/1.1 200 OK\r\nDate: Mon, 27 Oct 2025 22:20:43 GMT\r\nContent-Length: 2\r\nContent-Type: text/plain; charset=utf-8\r\nConnection: close\r\n\r\nOK", 137) = 137 <0.000169>
[pid 2995239<coredns>] 23:20:43.252971 read(14<socket:[254938647]>, "", 1) = 0 <0.000061>
[pid 2995209<coredns>] 23:20:43.505587 --- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=1<coredns>, si_uid=65532} ---
[pid 2995209<coredns>] 23:20:43.595818 socket(AF_INET6, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 14<socket:[254939651]> <0.000061>
[pid 2995209<coredns>] 23:20:43.595957 setsockopt(14<socket:[254939651]>, SOL_IPV6, IPV6_V6ONLY, [0], 4) = 0 <0.000044>
[pid 2995209<coredns>] 23:20:43.596034 setsockopt(14<socket:[254939651]>, SOL_SOCKET, SO_BROADCAST, [1], 4) = 0 <0.000008>
[pid 2995209<coredns>] 23:20:43.596070 connect(14<socket:[254939651]>, {sa_family=AF_INET6, sin6_port=htons(53), sin6_flowinfo=htonl(0), inet_pton(AF_INET6, "2001:730:3e42::53", &sin6_addr), sin6_scope_id=0}, 28) = -1 ENETUNREACH (Network is unreachable) <0.000016>
[pid 2995209<coredns>] 23:20:43.685853 write(6<pipe:[94734928]>, "\0", 1) = 1 <0.000065>
```
