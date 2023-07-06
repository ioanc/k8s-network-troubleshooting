/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// serverCmd represents the server command
var serverCmd = &cobra.Command{
	Use:   "server",
	Short: "A brief description of your command",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("server called")
	},
}

func init() {

	rootCmd.CompletionOptions.DisableDefaultCmd = true

	rootCmd.AddCommand(serverCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// serverCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command

	// serverCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
	// serverCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
	// rootCmd.Flags().StringVarP(&ip, "ip", "i", "", "Username (required if password is set)")

	var ip string
	var port string

	serverCmd.Flags().StringVarP(&ip, "ip", "i", "", "ip addres (required)")
	serverCmd.Flags().StringVarP(&port, "port", "p", "", "port (required)")
	serverCmd.MarkFlagsRequiredTogether("ip", "port")
}
