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

Generates the following sample data under 'localhost:8000':

"""
