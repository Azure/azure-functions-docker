package mount

import (
	"bytes"
	"fmt"
	"init-server/pkg/logger"
	"net"
	"net/http"
	"os"
	"os/exec"
	"syscall"
)

func run(cmd *exec.Cmd) (string, string, error) {
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()

	fmt.Println(stdout.String())
	fmt.Println(stderr.String())

	return stdout.String(), stderr.String(), err
}

func getIp(host string) (string, error) {
	ips, err := net.LookupIP(host)
	if err != nil {
		return "", err
	}

	for _, ip := range ips {
		if ip.To4() != nil {
			return ip.String(), nil
		}
	}
	return "", fmt.Errorf("Can't find ipv4 for host %s", host)
}

func callMountCifs(host, accountName, accountKey, contentShare, targetPath string) (string, string, error) {

	logger.Log("Init callMountCifs")

	cmd := exec.Command("mount",
		"-t",
		"cifs",
		fmt.Sprintf("//%s/%s", host, contentShare),
		targetPath,
		"-o",
		fmt.Sprintf("vers=3.0,username=%s,password=%s,dir_mode=0777,file_mode=0777,serverino", accountName, accountKey))
	return run(cmd)
}

func callMountSyscall(host, accountName, accountKey, contentShare, targetPath string) error {
	logger.Log("Init callMountSyscall")

	ip, err := getIp(host)
	if err != nil {
		logger.Log("Failed to get Ip Address in callMountSyscall")
		return err
	}

	logger.Log(fmt.Sprintf("Storage host ip =: %s\n", ip))

	err = syscall.Mount(fmt.Sprintf("//%s/%s", host, contentShare),
		targetPath,
		"cifs",
		0,
		fmt.Sprintf("ip=%s,unc=\\\\%s\\%s,vers=3.0,username=%s,password=%s,dir_mode=0777,file_mode=0777,serverino", ip, host, contentShare, accountName, accountKey))

	if err != nil {
		logger.Log(fmt.Sprintf("syscall.Mount failed: %s", err.Error()))
		fmt.Println("%v", err)
	}

	return err
}

// RunCifs runs mount -t cifs to mount a cifs file share
func RunCifs(req *http.Request) (string, string, error) {
	logger.Log("Init RunCifs")

	return runCifsInternal(req.FormValue("host"),
		req.FormValue("accountName"),
		req.FormValue("accountKey"),
		req.FormValue("contentShare"),
		req.FormValue("targetPath"))
}

func runCifsInternal(host, accountName, accountKey, contentShare, targetPath string) (string, string, error) {
	logger.Log("Init runCifsInternal")

	if host == "" || accountName == "" || accountKey == "" || contentShare == "" || targetPath == "" {
		return "", "", fmt.Errorf("host, accountName, accountKey, contentShare and targetPath are required")
	}

	logger.Log("Creating directory..")

	// make sure targetPath exists
	err := os.MkdirAll(targetPath, os.ModePerm)
	if err != nil {
		logger.Log("Creating directory failed")
		return "", "", err
	}

	logger.Log("Created directory successfully")

	err = callMountSyscall(host, accountName, accountKey, contentShare, targetPath)

	if err != nil {
		logger.Log(fmt.Sprintf("Mount by syscall failed. Attempting to mount using mount cmd"))
		return callMountCifs(host, accountName, accountKey, contentShare, targetPath)
	} else {
		logger.Log(fmt.Sprintf("Mount by syscall succeeded."))
	}

	return "", "", nil
}
