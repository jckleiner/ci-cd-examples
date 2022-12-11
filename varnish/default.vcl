vcl 4.0;

# host.docker.internal works only for mac

backend default {
    .host = "host.docker.internal";
    .port = "2222";
}

