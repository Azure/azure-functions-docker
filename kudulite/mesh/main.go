package main

import (
	"fmt"
	"init-server/pkg/logger"
	"init-server/pkg/mount"
	"net/http"
)

// These are internal operations available for kudulite.
type internalFunc func(req *http.Request) (string, string, error)

var internalFunctions = map[string]internalFunc{
	"cifs": mount.RunCifs,
}

// init server listens on 6060 and accepts request for mounting CIFS file systems
func startInitServer() {
	logger.Log("Starting functions handler")

	mux := http.NewServeMux()
	server := http.Server{Addr: "localhost:6060", Handler: mux}

	mux.HandleFunc("/", func(res http.ResponseWriter, req *http.Request) {
		req.ParseForm()
		operation := req.FormValue("operation")

		logger.Log(fmt.Sprintf("Starting operation: %s\n", operation))

		var err error
		var stdout, stderr string

		if f, operationFound := internalFunctions[operation]; operationFound {
			stdout, stderr, err = f(req)
		} else {
			err = fmt.Errorf("operation type is invalid")
		}

		if err != nil {
			res.WriteHeader(400)
			fmt.Fprintf(res, "err: %s\nerror: %s\noutput: %s", err.Error(), stderr, stdout)
		} else {
			res.WriteHeader(200)
			fmt.Fprint(res, "OK")
		}
	})

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		logger.Error(err.Error())
	}
}

func main() {
	fmt.Println("Starting init server...")
	startInitServer()
}
