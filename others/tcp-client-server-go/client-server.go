package main

import (
	"bufio"
	"flag"
	"fmt"
	"net"
	"os"
	"strings"
	"time"
)

func server(address string, port string, KeepAlive bool, idle time.Duration) {

	// Resolve TCP Address
	addrport := address + ":" + port
	addr, err := net.ResolveTCPAddr("tcp", addrport)
	if err != nil {
		fmt.Printf("Unable to resolve IP")
	}
	l, err := net.ListenTCP("tcp", addr)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer l.Close()

	c, err := l.AcceptTCP()
	if err != nil {
		fmt.Println(err)
		return
	}
	// Enable / Disable Keepalives

	err = c.SetKeepAlive(KeepAlive)
	if err != nil {
		fmt.Printf("Unable to set keepalive - %s", err)
	}
	if KeepAlive {
		err = c.SetKeepAlivePeriod(25 * time.Second)
		if err != nil {
			fmt.Printf("Unable to set keepalivePeriod - %s", err)
		}
	}

	for {
		netData, err := bufio.NewReader(c).ReadString('\n')
		if err != nil {
			fmt.Println(err)
			return
		}

		if strings.TrimSpace(string(netData)) == "STOP" {
			fmt.Println("Exiting TCP server!")
			return
		}
		fmt.Print("-> ", string(netData))

		// i, err := strconv.Atoi(idle)
		// if err != nil {
		// 	fmt.Println(err)
		// 	return
		// }

		fmt.Println((time.Now()).Format(time.RFC3339 + "\n"))

		// time.Sleep((time.Duration(i) * time.Second))
		time.Sleep(idle)

		fmt.Print("-> replay", "\n")
		fmt.Println((time.Now()).Format(time.RFC3339 + "\n"))

		t := time.Now()
		myTime := t.Format(time.RFC3339 + "\n")
		c.Write([]byte(myTime))
	}
}

func client(address string, port string) {

	// Resolve TCP Address
	addrport := address + ":" + port
	addr, err := net.ResolveTCPAddr("tcp", addrport)
	if err != nil {
		fmt.Printf("Unable to resolve IP")
	}

	c, err := net.DialTCP("tcp", nil, addr)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Keepalives controlled on server side
	// err = c.SetKeepAlive(false)
	// if err != nil {
	// 	fmt.Printf("Unable to set keepalive - %s", err)
	// }

	for {
		reader := bufio.NewReader(os.Stdin)
		fmt.Print(">> ")
		text, _ := reader.ReadString('\n')
		fmt.Fprintf(c, text+"\n")

		message, _ := bufio.NewReader(c).ReadString('\n')
		fmt.Print("->: " + message)
		if strings.TrimSpace(string(text)) == "STOP" {
			fmt.Println("TCP client exiting...")
			return
		}
	}
}

var serverKeepAlive *bool
var serverIpCmd *string
var serverPortCmd *string
var serverIdleCmd *time.Duration

var remoteIpCmd *string
var remotePortCmd *string

func main() {

	serverCmd := flag.NewFlagSet("server", flag.ExitOnError)
	serverKeepAlive := serverCmd.Bool("keepalive", true, "keepAlive")
	serverIpCmd := serverCmd.String("ip", "0.0.0.0", "listening ip address")
	serverPortCmd := serverCmd.String("port", "12345", "listening server port")
	serverIdleCmd := serverCmd.Duration("idle", 30*time.Second, "idle time duration in seconds")

	clientCmd := flag.NewFlagSet("client", flag.ExitOnError)
	remoteIpCmd := clientCmd.String("ip", "", "remote ip address")
	remotePortCmd := clientCmd.String("port", "12345", "remote port port")

	if len(os.Args) < 2 {
		fmt.Println("Expect 'client' or 'server'")
		os.Exit(1)
	}

	switch os.Args[1] {

	case "server":
		serverCmd.Parse(os.Args[2:])
		fmt.Println("Running as server:")
		fmt.Println("  keepalive", *serverKeepAlive)
		fmt.Println("  IP address:", *serverIpCmd)
		fmt.Println("  Port:", *serverPortCmd)
		fmt.Println("  Idle:", *serverIdleCmd)

		server(*serverIpCmd, *serverPortCmd, *serverKeepAlive, *serverIdleCmd)

	case "client":
		clientCmd.Parse(os.Args[2:])

		if *remoteIpCmd == "" {
			fmt.Println("Running as client:")
			fmt.Println("  -IP remote address missing")
			fmt.Println("  Remote Port:", *remotePortCmd)
			return

		} else {
			fmt.Println("Running as client:")
			fmt.Println("  Remote IP:", *remoteIpCmd)
			fmt.Println("  Remote Port:", *remotePortCmd)

			client(*remoteIpCmd, *remotePortCmd)
		}

	default:
		fmt.Println("expected 'client' or 'server' subcommands")
		os.Exit(1)

	}
}
