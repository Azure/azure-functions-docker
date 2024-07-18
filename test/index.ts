import axios from "axios";
import chalk from "chalk";
import path from "path";
import shell from "shelljs";

if (process.argv.length < 2) {
  console.error(chalk.red.bold("expected an image name"));
  process.exit(1);
}

const storagePath =
  "https://functionsdockertests.blob.core.windows.net/public/docker";

const dotnetIsolated5 = {
  package: `${storagePath}/dotnet-isolated-functions.zip`,
  invoke: "/api/DotnetIsolatedHttpFunction",
  response: "Hello, Test"
}

const dotnetIsolated6 = {
  package: `${storagePath}/dotnet-isolated6-functions.zip`,
  invoke: "/api/DotnetIsolatedHttpFunction",
  response: "Hello, Test"
}

const dotnetIsolated7 = {
  package: `${storagePath}/dotnet-isolated7-functions.zip`,
  invoke: "/api/DotnetIsolated7HttpFunction",
  response: "Welcome to Azure Functions! .NET 7 Preview 5"
}

const dotnetIsolated8 = {
  package: `${storagePath}/dotnet-isolated8-functions.zip`,
  invoke: "/api/DotnetIsolated8HttpFunction",
  response: "Welcome to Azure Functions! .NET 8"
}

const dotnetInProc8 = {
  package: `${storagePath}/dotnet8-inproc.zip`,
  invoke: "/api/CSharpHttpFunction?name=Test",
  response: "Hello, Test. This HTTP triggered function executed successfully."
}

const map = {
  python: {
    package: `${storagePath}/python-functions.zip`,
    invoke: "/api/PythonHttpTrigger?name=Test",
    response: "Hello Test!"
  },
  powershell: {
    package: `${storagePath}/powershell-functions.zip`,
    invoke: "/api/PowershellHttpTrigger?name=Test",
    response: "Hello Test"
  },
  node: {
    package: `${storagePath}/node-functions.zip`,
    invoke: "/api/JsHttpTrigger?name=Test",
    response: "Hello Test"
  },
  dotnet: {
    package: `${storagePath}/dotnet-functions.zip`,
    invoke: "/api/CSharpHttpFunction?name=Test",
    response: "Hello, Test"
  },
  java: {
    package: `${storagePath}/java-functions.zip`,
    invoke: "/api/HttpTrigger-Java?name=Test",
    response: "Hello, Test"
  }
};

const imageName = process.argv[process.argv.length - 1];
console.log("Image name: " + imageName);

const testData = (function() {
  if (imageName.indexOf("java") !== -1) return map.java;
  else if (imageName.indexOf("powershell") !== -1) return map.powershell;
  else if (imageName.indexOf("python") !== -1) return map.python;
  else if (imageName.indexOf("node") !== -1) return map.node;
  else if (imageName.indexOf("dotnet-isolated5.0") !== -1) return dotnetIsolated5;
  else if (imageName.indexOf("dotnet-isolated6.0") !== -1) return dotnetIsolated6;
  else if (imageName.indexOf("dotnet-isolated7.0") !== -1) return dotnetIsolated7;
  else if (imageName.indexOf("dotnet-isolated8.0") !== -1) return dotnetIsolated8;
  else if (imageName.indexOf("dotnet8") !== -1) return dotnetInProc8;
  else if (imageName.indexOf("mesh") !== -1) return map;
  else return map.dotnet;
})();

const random = () => {
  return (
    Math.random()
      .toString(36)
      .substring(2, 15) +
    Math.random()
      .toString(36)
      .substring(2, 15)
  );
};

const dockerFile = (function() {
  let fileName = "test.Dockerfile";

  if (imageName.indexOf("nanoserver") !== -1) {
    fileName = "test-win.Dockerfile";
  } else if (imageName.indexOf("alpine") !== -1) {
    fileName = "test-alpine.Dockerfile";
  } else if (imageName.indexOf("mariner") !== -1) {
    fileName = "test-mariner.Dockerfile";
  }

  return path.join(__dirname, fileName);
})();

const name = random();

const runTest = async (data: typeof map.dotnet, envStr = "") => {
  if (
    shell.exec(
      `docker build -t ${name} --build-arg BASE_IMAGE=${imageName} --build-arg CONTENT_URL=${data.package} -f ${dockerFile} ${__dirname}`
    ).code !== 0
  ) {
    console.error("Error building image");
    process.exit(1);
  }

 // test for host images
if (imageName.indexOf("-core-tools") === -1) {
  const { stdout: containerId, code: exitCodeStart } = shell.exec(
    `docker run --rm -p 9097:80 ${envStr} -d ${name}`
  );

  if (exitCodeStart !== 0) {
    console.error("Error starting container");
    process.exit(1);
  }

  console.log(chalk.yellow.bold("current containerId: " + containerId));

  // Function to wait for a specific amount of time
  const timeout = (ms: number) => new Promise(res => setTimeout(res, ms));

  // Wait for container to initialize
  await timeout(imageName.indexOf("arm32v7") === -1 ? 5_000 : 30_000);

  let error = false;
  let trials = 0;

  do {
    trials++;
    try {
      // Check container status
      const { stdout: status, code: exitCodeStatus } = shell.exec(
        `docker inspect -f '{{.State.Status}}' ${containerId}`
      );

      if (exitCodeStatus !== 0) {
        console.error("Error inspecting container status");
        process.exit(1);
      }

      console.log(chalk.yellow.bold(`Container Status: ${status.trim()}`));

      if (status.trim() === "exited") {
        // Container exited, check exit code
        const { stdout: exitCode, code: exitCodeExit } = shell.exec(
          `docker inspect -f '{{.State.ExitCode}}' ${containerId}`
        );

        if (exitCodeExit !== 0) {
          console.error(`Container exited with code ${exitCode.trim()}`);
          process.exit(1);
        }

        console.log(chalk.yellow.bold("Container exited successfully"));
        error = true; // Exit loop since container exited
        break;
      }

      // Container is running, perform HTTP request validation
      const res = await axios.get(`http://localhost:9097${data.invoke}`, {
        timeout: 10_000
      });

      if (res.data !== data.response) {
        console.error(
          chalk.red.bold(
            "Error: Expected: " +
              chalk.green(data.response) +
              " but got: " +
              chalk.yellow(res.data)
          )
        );
        error = true;
      } else {
        console.log(
          chalk.green(
            `${imageName} successfully ran ${chalk.blue(
              data.invoke
            )} function with: ${chalk.grey(
              `(${res.status}: ${res.statusText})`
            )} ${chalk.grey(res.data)}`
          )
        );
        error = false;
      }
    } catch (e) {
      console.error(chalk.red(e));
      error = true;
    }

    if (error) {
      await timeout(5_000);
    }
  } while (error && trials < 10);

  // Cleanup: Kill container and remove image
  shell.exec(`docker kill ${containerId}`);
  shell.exec(`docker rmi ${name}`);

  if (error) {
    process.exit(1);
  }
} else {
    if (shell.exec(`docker run ${name} func --help`).code !== 0) {
      console.error("Azure Functions Core Tools Not found.");
      process.exit(1);
    }
    if (shell.exec(`docker run ${name} az --help`).code !== 0) {
      console.error("Azure CLI Not Found.")
      process.exit(1);
    }
  }

};

async function main() {
  if ("package" in testData) {
    await runTest(testData);
  } else {
    await runTest(testData.dotnet, "-e FUNCTIONS_WORKER_RUNTIME=dotnet");
    await runTest(testData.node, "-e FUNCTIONS_WORKER_RUNTIME=node");
    await runTest(testData.python, "-e FUNCTIONS_WORKER_RUNTIME=python");
    await runTest(testData.java, "-e FUNCTIONS_WORKER_RUNTIME=java");

    // PowerShell 7.2 is only supported in Functions V4.
    // If image name contains '/4/' in the path, run the PowerShell 7.2 tests
    if (imageName.includes("/4/")) {
      await runTest(testData.powershell, "-e FUNCTIONS_WORKER_RUNTIME=powershell -e FUNCTIONS_WORKER_RUNTIME_VERSION=7");
      await runTest(testData.powershell, "-e FUNCTIONS_WORKER_RUNTIME=powershell -e FUNCTIONS_WORKER_RUNTIME_VERSION=7.2");
    }
  }
}

main();
