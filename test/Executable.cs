using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

namespace Test
{
    internal class Executable
    {
        private string _arguments;
        private string _exeName;
        private bool _shareConsole;
        private bool _streamOutput;
        private readonly bool _visibleProcess;
        private readonly string _workingDirectory;

        public Executable(string exeName, string arguments = null, bool streamOutput = true, bool shareConsole = false, bool visibleProcess = false, string workingDirectory = null)
        {
            _exeName = exeName;
            _arguments = arguments;
            _streamOutput = streamOutput;
            _shareConsole = shareConsole;
            _visibleProcess = visibleProcess;
            _workingDirectory = workingDirectory;
        }

        public string Command => $"{_exeName} {_arguments}";

        public Process Process { get; private set; }

        public int Run(Action<string> outputCallback = null, Action<string> errorCallback = null, TimeSpan? timeout = null)
        {
            Console.WriteLine($"> {Command}");

            var processInfo = new ProcessStartInfo
            {
                FileName = _exeName,
                Arguments = _arguments,
                CreateNoWindow = !_visibleProcess,
                UseShellExecute = _shareConsole,
                RedirectStandardError = _streamOutput,
                RedirectStandardInput = _streamOutput,
                RedirectStandardOutput = _streamOutput,
                WorkingDirectory = _workingDirectory ?? Environment.CurrentDirectory
            };

            Process process = null;

            try
            {
                process = Process.Start(processInfo);
            }
            catch (Win32Exception ex)
            {
                if (ex.Message == "The system cannot find the file specified")
                {
                    throw new FileNotFoundException(ex.Message, ex);
                }
                throw ex;
            }

            if (_streamOutput)
            {
                if (outputCallback != null)
                {
                    process.OutputDataReceived += (s, e) =>
                    {
                        if (e.Data != null)
                        {
                            outputCallback(e.Data);
                        }
                    };
                    process.BeginOutputReadLine();
                }

                if (errorCallback != null)
                {
                    process.ErrorDataReceived += (s, e) =>
                    {
                        if (!string.IsNullOrWhiteSpace(e.Data))
                        {
                            errorCallback(e.Data);
                        }
                    };
                    process.BeginErrorReadLine();
                }
                process.EnableRaisingEvents = true;
            }
            if (timeout != null)
            {
                process.WaitForExit((int)timeout.Value.TotalMilliseconds);
            }
            else
            {
                process.WaitForExit();
            }
            return process.ExitCode;
        }
    }
}