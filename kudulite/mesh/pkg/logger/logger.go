package logger

import (
	"fmt"
	"os"
	"strings"
)

var (
	containerName  = ""
	stampName      = ""
	tenantID       = ""
	kuduLogsFormat = "MS_KUDU_LOGS %d,%s,%s,%s,%s,%d,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%d,%d,%s,%s,%s\n"
)

func init() {
	containerName = os.Getenv("CONTAINER_NAME")
	stampName = os.Getenv("WEBSITE_HOME_STAMPNAME")
	tenantID = os.Getenv("WEBSITE_STAMP_DEPLOYMENT_ID")
}

func getSiteName() string {

	const placeholderAppName string = "mesh-placeholder"
	specializedAppName := os.Getenv("WEBSITE_SITE_NAME")

	if len(specializedAppName) > 0 {
		return strings.ToLower(specializedAppName)
	}

	return placeholderAppName
}

// Error logs errors
func Error(msg string) {
	logKudu(msg, 2)
}

// Warning logs warnings
func Warning(msg string) {
	logKudu(msg, 3)
}

// Log - logs
func Log(msg string) {
	logKudu(msg, 4)
}

func logKudu(msg string, level int) {
	var (
		summary         = fmt.Sprintf("\"%s\"", strings.Replace(msg, "\n", " ", -1))
		errorString     = fmt.Sprintf("\"%s\"", strings.Replace("", "\n", " ", -1))
		exceptionString = fmt.Sprintf("\"%s\"", strings.Replace("", "\n", " ", -1))
	)

	fmt.Printf(kuduLogsFormat,
		level,
		getSiteName(),
		"", // project type
		"", //result
		errorString,
		0,  // deployment duration Ms
		"", //sitemode
		"", //scm type
		"", //vs project id
		"", // jobname
		"", //script extensio
		"", //jobType
		"", //trigger
		"", //method
		"", //path
		summary,
		exceptionString,
		"", //route
		"", //user agent
		"", //requestId
		"", //buildversion
		"", //address
		"", //verb
		0,  // statuscode
		0,  // latencyInMs
		stampName,
		tenantID,
		containerName)
}
