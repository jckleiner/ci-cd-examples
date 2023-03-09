vcl 4.0;

# host.docker.internal works only for mac
import std;

# The Varnish container runs on localhost:8080
# by default, requests coming to localhost:8080 will be answered/cached from localhost:2222
backend default {
    .host = "host.docker.internal";
    .port = "2222";
}


sub vcl_recv {
  # Goes to 'varnishlog', can be seen with 'varnishlog -g raw', better way?
  std.log("varnish log info: " + req.url);

  # varnishlog -b   Only display backend records
  # varnishlog -c   Only display client records (we are the client in this case with our Postman)
  
  # TODO - learn more about how varnishncsa works (see https://varnish-cache.org/docs/trunk/reference/varnishncsa.html)
  # TODO - try to log out to /var/log/varnish/varnishncsa.log?

  # TODO - Test how the 'Expires' header affect the Varnish cache (see HttpCachingSupport::createCacheControl)

  # TODO - Note: If there is a Cache-Control header with the max-age or s-maxage directive in the response, the Expires header is ignored. 

  # Goes to syslog
  # On my Ubuntu machine, I can see the output at /var/log/syslog.
  # On a RHEL/CentOS machine, the output is found in /var/log/messages.
  # This is controlled by the rsyslog service, so if this is disabled for some reason you may need to start it with systemctl start rsyslog.
  # As noted by others, your syslog() output would be logged by the /var/log/syslog file.
  # You can see system, user, and other logs at /var/log.
  # Since the container does not have the rsyslog service, probably that's why it is not being logged
  std.syslog(9, "RECV: " + req.http.host + req.url);

  # if matches the regex, checks also if string is contained in the other string
  if (req.url ~ "gzip") {
    return(synth(512, "Invalid URL"));
  }

}
