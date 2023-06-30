package main

import (
        "bufio"
        "fmt"
        "net"
        "os"
        "strings"
        "time"
        "strconv"
)

func main() {
        arguments := os.Args
        if len(arguments) == 1 {
                fmt.Println("Please provide 'address port'")
                return
        }

                // Resolve TCP Address
                PORT := arguments[1] + ":" + arguments[2]
                addr, err := net.ResolveTCPAddr("tcp", PORT)
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
                err = c.SetKeepAlive(false)
                if err != nil {
                        fmt.Printf("Unable to set keepalive - %s", err)
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

                i, err := strconv.Atoi(arguments[3])
                   if err != nil {
                        fmt.Println(err)
                        return
                }
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
          
