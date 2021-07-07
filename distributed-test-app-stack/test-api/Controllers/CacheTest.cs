using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;

namespace RESTTestApi.Controllers
{
    public class KeyValue
    {
        public string Key { get; set; }
        public string Value { get; set; }
    }

    [ApiController]
    [Route("[controller]")]
    public class CacheTest : ControllerBase
    {
        [HttpGet("test-redis-connection")]
        public string TestRedisConnection(string key)
        {
            string sentinelIp = Environment.GetEnvironmentVariable("SENTINEL_SERVICENAME");
            try
            {
                var options = ConfigurationOptions.Parse($"{sentinelIp},serviceName=mymaster");
                options.AllowAdmin = true;
                var conn = ConnectionMultiplexer.Connect(options);
                return conn.IsConnected ? "connection success" : "connection failure";
            }
            catch (Exception ex)
            {
                return $"connection failure. error: {ex.Message} " +
                    $"sentinel ip supplied: {sentinelIp}";
            }
        }

        [HttpGet("{key}")]
        public string Get(string key)
        {
            string sentinelHost = Environment.GetEnvironmentVariable("SENTINEL_SERVICENAME");
            var options = ConfigurationOptions.Parse($"{sentinelHost},serviceName=mymaster");
            options.AllowAdmin = true;
            var conn = ConnectionMultiplexer.Connect(options);
            var db = conn.GetDatabase();
            var val = db.StringGet(key);
            return val;
        }

        [HttpPost]
        public bool Set([FromBody]KeyValue keyVal)
        {
            string sentinelHost = Environment.GetEnvironmentVariable("SENTINEL_SERVICENAME");
            var options = ConfigurationOptions.Parse($"{sentinelHost},serviceName=mymaster");
            options.AllowAdmin = true;
            var conn = ConnectionMultiplexer.Connect(options);
            var db = conn.GetDatabase();
            return db.StringSet(keyVal.Key, keyVal.Value);
        }
    }
}
