from prometheus_client import start_http_server, Gauge
import random
import time

# create a gauge to track the number of requests
requests_total = Gauge('myapp_requests_total', 'Total number of requests')

# create a gauge to track the number of active users
active_users = Gauge('myapp_active_users', 'Number of active users')

# create a gauge to track the system load average
system_load = Gauge('myapp_system_load', 'System load average')

# start the Prometheus HTTP server on port 8000
start_http_server(8000)

# simulate some activity for our application
while True:
    # increment the request counter
    requests_total.inc()

    # generate a random number of active users
    num_users = random.randint(0, 1000)
    active_users.set(num_users)

    # read the system load average and update the metric
    with open('/proc/loadavg', 'r') as f:
        loadavg = f.read().split()[0]
        system_load.set(float(loadavg))

    # sleep for a bit before repeating
    time.sleep(10)

"""
pip3 install -r requirements.txt

Generates the following data:

# HELP myapp_requests_total Total number of requests
# TYPE myapp_requests_total gauge
myapp_requests_total 4.0
# HELP myapp_system_load System load average
# TYPE myapp_system_load gauge
myapp_system_load 0.24
# HELP myapp_active_users Number of active users
# TYPE myapp_active_users gauge
myapp_active_users 29.0
# HELP process_virtual_memory_bytes Virtual memory size in bytes
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 95748096.0
# HELP process_resident_memory_bytes Resident memory size in bytes
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 15073280.0
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1678298292.35
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 0.09
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 6
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 1024.0
"""