using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Test
{
    public static class DockerHelpers
    {
        public static void DockerBuild(string tag, string file, string baseImage, string url, string dir) =>
            RunDockerCommand($"build -t {tag} --build-arg BASE_IMAGE={baseImage} --build-arg CONTENT_URL={url} -f {file} {dir}");

        public static void KillContainer(string containerId, bool ignoreError = false) => RunDockerCommand($"kill {containerId}", containerId, ignoreError);

        public static string DockerLogs(string containerId)
        {
            (var output, _) = RunDockerCommand($"logs {containerId}");
            return output.ToString().Trim();
        }

        public static void RemoveImage(string imageName) => RunDockerCommand($"rmi {imageName}");

        public static string DockerRun(string image, int port, Dictionary<string, string> environmentVariables = null)
        {
            var env = string.Empty;
            if (environmentVariables != null)
            {
                env = environmentVariables.Aggregate(string.Empty, (a, b) => $"{a} -e {b.Key}={b.Value}");
            }

            (var output, _) = RunDockerCommand($"run --rm -p {port}:80 {env} -d {image}");
            return output.ToString().Trim();
        }

        internal static bool VerifyDockerAccess()
        {
            var docker = new Executable("docker", "ps");
            var sb = new StringBuilder();
            var exitCode = docker.Run(l => sb.AppendLine(l), e => sb.AppendLine(e));
            if (exitCode != 0 && sb.ToString().IndexOf("permission denied", StringComparison.OrdinalIgnoreCase) != 0)
            {
                throw new Exception("Got permission denied trying to run docker. Make sure the user you are running the cli from is in docker group or is root");
            }
            return true;
        }

        private static (string output, string error) InternalRunDockerCommand(string args, bool ignoreError)
        {
            var docker = new Executable("docker", args);
            var sbError = new StringBuilder();
            var sbOutput = new StringBuilder();

            var exitCode = docker.Run(l => sbOutput.AppendLine(l), e => sbError.AppendLine(e));

            if (exitCode != 0 && !ignoreError)
            {
                throw new Exception($"Error running {docker.Command}.\n" +
                    $"output: {sbOutput.ToString()}\n{sbError.ToString()}");
            }

            return (sbOutput.ToString(), sbError.ToString());
        }

        private static (string output, string error) RunDockerCommand(string args, string containerId = null, bool ignoreError = false)
        {
            var printArgs = string.IsNullOrWhiteSpace(containerId)
                ? args
                : args.Replace(containerId, containerId.Substring(0, 6));
            Console.Write($"Running 'docker {printArgs}'.");
            (var output, var error) = InternalRunDockerCommand(args, ignoreError);

            Console.WriteLine($"Output: {output}");
            Console.WriteLine($"Error: {error}");
            return (output, error);
        }
    }
}