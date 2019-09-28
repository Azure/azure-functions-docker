import axios from "axios";
import chalk from "chalk";
import path from "path";
import shell, { test } from "shelljs";

if (process.argv.length < 2) {
  console.error(chalk.red.bold("expected an image name"));
  process.exit(1);
}

const storagePath =
  "https://functionstests.blob.core.windows.net/public/docker";

const map = {
  python: {
    package: `https://functionstestsahmels.blob.core.windows.net/public/python-functions.zip`,
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

const testData = (function() {
  if (imageName.indexOf("java") !== -1) return map.java;
  else if (imageName.indexOf("powershell") !== -1) return map.powershell;
  else if (imageName.indexOf("python") !== -1) return map.python;
  else if (imageName.indexOf("node") !== -1) return map.node;
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

const dockerFile = path.join(__dirname, "test.Dockerfile");
const name = random();

if (
  shell.exec(
    `docker build -t ${name} --build-arg BASE_IMAGE=${imageName} --build-arg CONTENT_URL=${testData.package} -f ${dockerFile} ${__dirname}`
  ).code !== 0
) {
  console.error("Error building image");
  process.exit(1);
}

const { stdout: containerId, code: exitCode } = shell.exec(
  `docker run --rm -p 9097:80 -d ${name}`
);

//const containerId = stdout
if (exitCode !== 0) {
  console.error("Error running container");
  process.exit(1);
}

console.log(chalk.yellow.bold("current containerId: " + containerId));

let error = false;
setTimeout(() => {
  axios
    .get(`http://localhost:9097${testData.invoke}`)
    .then(res => {
      if (res.data !== testData.response) {
        console.error(
          chalk.red.bold(
            "Error: Expected: " +
              chalk.green(testData.response) +
              " but got: " +
              chalk.yellow(res.data)
          )
        );
        error = true;
      } else {
        console.log(
          chalk.green(
            `${imageName} successfully ran ${chalk.blue(
              testData.invoke
            )} function with: ${chalk.grey(
              `(${res.status}: ${res.statusText})`
            )} ${chalk.grey(res.data)}`
          )
        );
      }
    })
    .catch(e => {
      console.error(chalk.red(e));
      error = true;
    })
    .finally(() => {
      shell.exec(`docker kill ${containerId}`);
      shell.exec(`docker rmi ${name}`);
      if (error) {
        process.exit(1);
      }
    });
}, 5000);
