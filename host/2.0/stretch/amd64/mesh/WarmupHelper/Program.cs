using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Text;

namespace Helper
{
    static class Program
    {
        static void Main(string[] args)
        {
            System.Threading.Thread.Sleep(TimeSpan.FromSeconds(10));
            const string content = "{\"isWarmup\":\"true\"}";

            var key = Environment.GetEnvironmentVariable("CONTAINER_ENCRYPTION_KEY");
            var token = SimpleWebTokenHelper.CreateToken(DateTime.UtcNow.AddMinutes(1), Convert.FromBase64String(key));
            using (var httpClient = new HttpClient())
            {
                httpClient.DefaultRequestHeaders.Add("x-ms-site-restricted-token", token);
                var response = httpClient.PostAsync("http://localhost:80/admin/instance/assign", new StringContent(content, Encoding.UTF8, "application/json")).Result;
                Console.WriteLine(response.StatusCode);
                response.EnsureSuccessStatusCode();
            }
        }
    }
}
