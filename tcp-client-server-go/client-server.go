package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"strconv"
	"strings"
	"time"
	//"flag"
)

func server(address string, port string, KeepAlive string, idle string) {

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
	SetKeepAlive, err := strconv.ParseBool(KeepAlive)
	if err != nil {
		fmt.Println(err)
		return
	}
	err = c.SetKeepAlive(SetKeepAlive)
	if err != nil {
		fmt.Printf("Unable to set keepalive - %s", err)
	}
	if SetKeepAlive {
		err = c.SetKeepAlivePeriod(60 * time.Second)
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

		i, err := strconv.Atoi(idle)
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println((time.Now()).Format(time.RFC3339 + "\n"))

		time.Sleep((time.Duration(i) * time.Second))

		fmt.Print("-> replay", "\n")
		fmt.Println((time.Now()).Format(time.RFC3339 + "\n"))

		t := time.Now()
		myTime := t.Format(time.RFC3339 + "\n")
		c.Write([]byte(myTime))
	}
}

func client(addressport string) {

	// Resolve TCP Address
	CONNECT := addressport
	addr, err := net.ResolveTCPAddr("tcp", CONNECT)
	if err != nil {
		fmt.Printf("Unable to resolve IP")
	}

	c, err := net.DialTCP("tcp", nil, addr)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Enable Keepalives
	err = c.SetKeepAlive(false)
	if err != nil {
		fmt.Printf("Unable to set keepalive - %s", err)
	}

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

func main() {

	arguments := os.Args
	if len(arguments) == 1 {
		fmt.Println("Please provide option: server or client")
		return
	} else {
		option := arguments[1]
		if option == "server" {
			server(arguments[2], arguments[3], arguments[4], arguments[5])
		} else if option == "client" {
			client(arguments[2])
		} else {
			fmt.Println("please use server or client")
		}
	}
}
