package main

import (
        "bufio"
        "fmt"
        "net"
        "os"
        "strings"
)

func main() {
        arguments := os.Args
        if len(arguments) == 1 {
                fmt.Println("Please provide host:port.")
                return
        }

                // Resolve TCP Address
                CONNECT := arguments[1]
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
