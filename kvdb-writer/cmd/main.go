package main

import (
	"flag"
	"os"

	"github.com/prometheus/common/log"
	"github.com/urfave/cli"
)

func main() {
	// Parse empty flags to suppress warnings from the snapshotter which uses
	// glog
	err := flag.CommandLine.Parse([]string{})
	if err != nil {
		log.Warnf("Error parsing flag: %v", err)
	}
	err = flag.Set("logtostderr", "true")
	if err != nil {
		log.Fatalf("Error setting glog flag: %v", err)
	}

	app := cli.NewApp()
	app.Name = "kvdb-writer"
	app.Usage = "CLI wrapper for PX kvdb util"
	app.Version = "0.1"
	app.Action = run

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:  "endpoints,e",
			Usage: "kvdb endpoints",
		},
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatalf("Error starting stork: %v", err)
	}
}

func run(c *cli.Context) {

}
