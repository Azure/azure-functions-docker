using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading;
using FluentAssertions;

namespace Test
{
    public static class TestRunner
    {
        private static HttpClient _client = new HttpClient(new LoggingHandler(new HttpClientHandler()));
        public static void Run(string imageName)
        {
            if (imageName.IndexOf("/azure-functions/dotnet") != -1)
            {
                RunDotnetTests(imageName);
            }
            else if (imageName.IndexOf("/azure-functions/node") != -1)
            {
                RunNodeTests(imageName);
            }
            else if (imageName.IndexOf("/azure-functions/powershell") != -1)
            {
                RunPowershellTests(imageName);
            }
            else if (imageName.IndexOf("/azure-functions/python") != -1)
            {
                RunPythonTests(imageName);
            }
            else if (imageName.IndexOf("/azure-functions/mesh") != -1)
            {
                RunMeshTests(imageName);
            }
            else if (imageName.IndexOf("/azure-functions/java") != -1)
            {
                RunJavaTests(imageName);
            }
            else
            {
                throw new Exception($"Can't find tests for image {imageName}");
            }
        }

        private static void RunMeshTests(string imageName)
        {
            RunDotnetTests(imageName, new Dictionary<string, string> { { "FUNCTIONS_WORKER_RUNTIME", "dotnet" } });
            RunNodeTests(imageName, new Dictionary<string, string> { { "FUNCTIONS_WORKER_RUNTIME", "node" } });
            RunPowershellTests(imageName, new Dictionary<string, string> { { "FUNCTIONS_WORKER_RUNTIME", "powershell" } });
            RunPythonTests(imageName, new Dictionary<string, string> { { "FUNCTIONS_WORKER_RUNTIME", "python" } });
        }

        private static void RunPythonTests(string imageName, Dictionary<string, string> additionalEnv = null)
        {
            RunTest(imageName,
                "https://functionstests.blob.core.windows.net/public/docker/python-functions-no-pyinstaller.zip",
                "/api/PythonHttpTrigger?name=Test",
                "Hello Test!",
                additionalEnv
            );
        }

        private static void RunPowershellTests(string imageName, Dictionary<string, string> additionalEnv = null)
        {
            RunTest(imageName,
                "https://functionstests.blob.core.windows.net/public/docker/powershell-functions.zip",
                "/api/PowershellHttpTrigger?name=Test",
                "Hello Test",
                additionalEnv
            );
        }

        private static void RunNodeTests(string imageName, Dictionary<string, string> additionalEnv = null)
        {
            RunTest(imageName,
                "https://functionstests.blob.core.windows.net/public/docker/node-functions.zip",
                "/api/JsHttpTrigger?name=Test",
                "Hello Test",
                additionalEnv
            );
        }

        private static void RunDotnetTests(string imageName, Dictionary<string, string> additionalEnv = null)
        {
            RunTest(imageName,
                "https://functionstests.blob.core.windows.net/public/docker/dotnet-functions.zip",
                "/api/CSharpHttpFunction?name=Test",
                "Hello, Test",
                additionalEnv
            );
        }

        private static void RunJavaTests(string imageName, Dictionary<string, string> additionalEnv = null)
        {
            RunTest(imageName,
                "https://functionstests.blob.core.windows.net/public/docker/java-functions.zip",
                "/api/HttpTrigger-Java?name=Test",
                "Hello, Test",
                additionalEnv
            );
        }

        private static void RunTest(string imageName, string url, string function, string expectedResponse, Dictionary<string, string> additionalEnv)
        {
            RunContainer(imageName, url, p =>
            {
                var response = _client.GetAsync($"http://localhost:{p}{function}").Result;
                var content = response.Content.ReadAsStringAsync().Result;
                content.Should().Be(expectedResponse);
            }, additionalEnv);
        }

        private static void RunContainer(string imageName, string url, Action<int> action, Dictionary<string, string> additionalEnv)
        {
            var dockerFilePath = GetDockerFilePath(imageName);
            var name = Path.GetRandomFileName().Replace(".", "");
            var env = new Dictionary<string, string>
            {
                { "AZURE_FUNCTIONS_ENVIRONMENT", "Development" },
            };

            if (additionalEnv != null)
            {
                env = env.Concat(additionalEnv).ToDictionary(k => k.Key, v => v.Value);
            }

            DockerHelpers.DockerBuild(name, dockerFilePath, imageName, url, Environment.CurrentDirectory);
            var containerId = DockerHelpers.DockerRun(name, 9097, env);
            Thread.Sleep(5000);

            try
            {
                action(9097);
            }
            finally
            {
                Console.WriteLine(DockerHelpers.DockerLogs(containerId));
                DockerHelpers.KillContainer(containerId);
                DockerHelpers.RemoveImage(name);
            }
        }

        private static string GetDockerFilePath(string imageName)
        {
            var dockerFileName = "test.Dockerfile";
            if (imageName.IndexOf("alpine") != -1)
            {
                dockerFileName = "test-alpine.Dockerfile";
            }

            var path = Path.GetFullPath(Path.Combine("data", dockerFileName));
            if (!File.Exists(path))
            {
                path = Path.GetFullPath(Path.Combine("test", "data", dockerFileName));
                File.Exists(path).Should().BeTrue("Can't find docker file to build");
            }
            return path;
        }
    }
}