# Varnish

Sources:
 * https://varnish-cache.org/docs/trunk/tutorial/
 * https://varnish-cache.org/docs/trunk/users-guide/index.html#users-guide-index
 * https://www.varnish-software.com/developers/tutorials/
 * https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching
 * https://docs.varnish-software.com/tutorials/object-lifetime/
 * https://docs.varnish-software.com/tutorials/

## Introduction to Varnish

### How Varnish works

For each and every request, Varnish runs through the ‘VCL’ program to decide what should happen: Which backend has this content, how long time can we cache it, is it accessible for this request, should it be redirected elsewhere and so on. If that particular backend is down, varnish can find another or substitute different content until it comes back up.

Your first VCL program will probably be trivial, for instance just splitting the traffic between two different backend servers:

```vcl
sub vcl_recv {
   if (req.url ~ "^/wiki") {
       set req.backend_hint = wiki_server;
   } else {
       set req.backend_hint = wordpress_server;
   }
}
```

When you load the VCL program into Varnish, it is compiled into a C-program which is compiled into a shared library, which varnish then loads and calls into, therefore VCL code is fast.

Everything Varnish does is recorded in ‘VSL’ log records which can be examined and monitored in real time or recorded for later use in native or NCSA format, and when we say ‘everything’ we mean everything.
These VSL log records are written to a circular buffer in shared memory, from where other programs can subscribe to them via a supported API. One such program is `varnishncsa` which produces NCSA-style log records:

`192.0.2.24 - - [08/Feb/2021:12:42:35 +0000] "GET http://vmods/ HTTP/1.1" 200 0 […]`

 * Varnish is also engineered for uptime, it is not necessary to restart varnish to change the VCL program, in fact, multiple VCL programs can be loaded at the same time and you can switch between them instantly.

### Caching with Varnish
When Varnish receives a request, VCL can decide to look for a reusable answer in the cache, if there is one, that becomes one less request to put load on your backend applications database. Cache-hits take less than a millisecond, often mere microseconds, to deliver.

If there is nothing usable in the cache, the answer from the backend can, again under VCL control, be put in the cache for some amount of time, so future requests for the same object can find it there.

Varnish understands the Cache-Control HTTP header if your backend server sends one, but ultimately the VCL program makes the decision to cache and how long, and if you want to send a different Cache-Control header to the clients, VCL can do that too.

### Limitations
(Not super sure, need to check in detail) In open-source version of varnish, the backend has to be HTTP because HTTPS is not supported. This is different in the payed version. 

### Starting Varnish Demo

Start the demo spring-boot application (runs on port 2222):

    cd ./varnish-demo-app
    mvn spring-boot:run

(not needed, use mvn) Start the demo spring-boot container:

    docker build -t varnish-demo-app ./varnish-demo-app/
    docker run -d --name app1 -p 2222:2222 --net var-net varnish-demo-app

Start the varnish container with our custom configuration:

    docker run \
        --rm \
        --name varnish \
        -p 8080:80 \
        -v ~/develop/personal/ci-cd-examples/varnish/default.vcl:/etc/varnish/default.vcl \
        varnish

### Backend

Varnish has a concept of **backend** or origin servers. A backend server is the server providing the content Varnish will accelerate via the cache.

In our case `/etc/varnish/default.vcl`:

```vcl
vcl 4.0;

backend default {
  .host = "127.0.0.1";
  .port = "8080";
}
```

This means we set up a backend in Varnish that fetches content from the localhost on port 8080.
Varnish can have several backends defined and can even join several backends together into clusters of backends for load balancing purposes, having Varnish pick one backend based on different algorithms.

### General

**Configuration**: The Varnish Configuration is written in VCL (Varnish Configuration Language). When Varnish is ran, this configuration is transformed into C code and then fed into a C compiler, loaded and executed.

So, as opposed to switching various settings on or off, you write polices on how the incoming traffic should be handled.

**varnishadm**: Varnish Cache has an admin console. You can connect it through the `varnishadm` command. In order to connect, the user needs to be able to read `/etc/varnish/secret` in order to authenticate.

Once you’ve started the console you can do quite a few operations on Varnish, like stopping and starting the cache process, load VCL, adjust the built in load balancer and invalidate cached content.

**varnishlog**: <u>Varnish does not log to disk. Instead it logs to a chunk of memory</u>. It is actually streaming the logs. At any time you’ll be able to connect to the stream and see what is going on. Varnish logs quite a bit of information. You can have a look at the logstream with the command `varnishlog`.

**VMODs**: Varnish modules. For instance `std` has many useful functions. (See https://varnish-cache.org/docs/trunk/reference/vmod_std.html)

**Matches Operator ~**: This operator `~` takes in a regular expression and it also checks if the string is contained in the other string.
For example, the following if check will be true if the url contains the string `test`

```vcl
  if (req.url ~ "test") {
    return(synth(512, "Invalid URL"));
  }
```

## User Guide

## Default Caching Behavior
Most of the modern apps do not send any cache-related headers (Cache-Control), thus the default (TTL) **120 seconds** apply if you installed Varnish and haven’t configured much.

So let's say you send the first request, the server is hit and the response is then cached for 120 seconds. During that time, all requests will be served from cache and a new request in those 120 seconds won't extend/restart the cache. Once the time is up, the next request will hit the backend again and will be cached for another 120 seconds.

> Time to live (TTL) is the time that an object is stored in a caching system before it’s deleted or refreshed.

It's worth noting that **only specific status codes are cacheable** in Varnish by default (at least so in Varnish 4.1 series).
It means that neither default TTL nor "calculated TTL" (from caching headers like s-maxage) would apply for non-cacheable status codes.
So if your response code is any different than the ones listed below, you might have to create VCL tweaks in order to make those cacheable.

Cacheable status codes:

    200: OK
    203: Non-Authoritative Information
    300: Multiple Choices
    301: Moved Permanently
    302: Moved Temporarily
    304: Not modified
    307: Temporary Redirect
    410: Gone
    404: Not Found

When a response has any of the given codes, and Varnish finds no caching headers in backend’s response, the initial cache lifetime (TTL) for it, will be set to the default TTL.
This is how long Varnish will cache an object by default.

## Object lifetime: TTL, Grace, Keep

Every copy of the content (aka object) stored in cache has a lifetime which defines how long an object can be considered fresh, or live, within the cache.

![](./img/object_lifetime.png)

The lifetime of a cached object is represented by the above timeline. The life of an object starts at the `t_origin` which is the time when the object was inserted in cache.

On top of this Timestamp we have three duration attributes:
 1. TTL - Time To Live
 2. Grace
 3. Keep

**An object lives in cache until TTL + Grace + Keep elapses**, after that time the object is removed by the Varnish daemon. Objects within the TTL are considered fresh objects, while stale objects are those whose lifetime is between TTL and Grace, this is called grace period. Object lifetime between t_origin and keep is used for conditional requests using the HTTP Header field `If-Modified-Since`.

**Setting TTLs, Grace and Keep:** Setting the right lifetime durations is fundamental for a healthy cache, avoid the waste of resources such as cache storage and make sure the users have a great quality of experience.
* You can set TTLs, grace and keep via VCL, CLI and HTTP headers

Before diving in and understand lifetime settings using examples, let’s clarify how Varnish handles TTLs/Grace/Keep. Varnish, when fetching the content to be cached, <u>will first check if any TTL-related header has been set by the origin server (for instance `Cache-Control`)</u>. If it has been set by the origin server, then Varnish will honor it, but we could still change it either via VCL or Varnish parameters if we need to apply a modification. If no TTLs have been set by the origin server, then Varnish will apply its own default TTLs.

### 1. Set via VCL
The flexibility of VCL gives us the freedom to set, rewrite, adjust any header/lifetime we need/want.

The right place to set TTLs is the `vcl_backend_response` function, that’s the subroutine where the origin server response is processed by Varnish and that’s where objects attributes can be changed before the content is stored in cache. Once an object is in cache it can’t be modified anymore.

An example for video content delivery:
```vcl
sub vcl_backend_response {
	# We first set TTLs valid for most of the content we need to cache
	set beresp.ttl = 10m;
	set beresp.grace = 2h;

	# We can now set specific TTLs based on the content we need to cache
	# For VoD content we set a medium-long TTL and a long grace as the VoD
	# content is very unlikely to change. This allow us to use the cache
	# for the most-requested content
	if (beresp.url ~ "/vod") {
		set beresp.ttl = 30m;
		set beresp.grace = 24h;
	}

	# For live content we use a very small TTL and a even smaller grace period
	# that's because live content is no longer *live* once it is consumed
	if (beresp.url ~ "/url") {
		set beresp.ttl = 10s;
		set beresp.grace = 2s;
	}

	# We expand the *keep* duration for IMS
	if (bereq.http.If-Modified-Since) {
		set beresp.keep = 10m;
	}
}
```

### 2. Set via CLI
See https://docs.varnish-software.com/tutorials/object-lifetime/#2-set-via-cli-cli

### 3. Set via HTTP headers
As mentioned in the introduction, <u>a HTTP caching strategy should start from the origin server(s), where the content is created, therefore it is really important to understand that we have a full set of HTTP headers we can use to define TTLs</u>.

Setting HTTP headers at the origin server is advisable, but if somehow those headers are not defined when the content is created you can always rely on VCL as explain at point 1.

 * `Cache-Control` header specifies directives which must be respected by all caching mechanisms. `Cache-Control: public, max-age=36000` means the response can be cached by any cache and it will be considered fresh for 36000 seconds Cache control has many directives which can be request or response specific. Check the RFC for more details.
* The `Expires` header field gives the date/time after which the response is considered stale. For example Expires: Thu, 01 Dec 2020 16:00:00 GMT
* The `Age` header field conveys the sender’s estimate of the amount of time since the response was generated or successfully validated at the origin server.
* `Etag`, `Last-Modified`, `If-Modified-Since`, `If-None-Match` these are conditional headers and must be used when sending cache validation request. The scope of those headers is to indicate if a cache has the most-up-to date version of the cached content or if fresher content can be server by the origin server. In example, if a client send a GET or a HEAD request with a `If-Modified-Since: Tue, 29 Oct 2019 19:43:31 GMT`, Varnish will revalidate the available content in cache by sending a conditional request to the origin server to check if the request content has been modified after Sat, 29 Oct 2019 19:43:31 GMT


### Examples for HTTP Cache Headers and Varnish Behavior
Read more about it here: https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching, it goes into detail about freshness, stale etc.

 * `Cache-Control: no-store`: Varnish won't cache the response.
 * `Cache-Control: max-age=40`: overrides the TTL to 40 seconds, instead of the default 120 seconds.

### Deciding on the correct default TTL value
The common approach to the matter of deciding on the correct value depends on your application. But for the most part, the correct strategy is setting the default TTL to a **really high value**: raise it to 2 weeks, and **make your application send a PURGE request to Varnish** when there’s a need to invalidate an object in the cache.
Or to adjust the caching by using the standard HTTP caching related headers like described in previous sections.

## Custom Headers From Varnish
Varnish will add some headers to its responses to the client:
 * `X-Varnish`: Custom Header. TODO
 * `Age`: Indicates the number of seconds the object has been in a proxy cache. If your second request is 30 seconds after the original, you'll get a header like `Age: 30`.
 * `Via`: Added by proxies and used to track message forwards, avoid request loops and identify protocol capabilities of senders. An example value is `1.1 b9d852e004f0 (Varnish/7.2)`

TODO: what type of directors there are? 
 * directors.fallback
 * directors.round_robin
 * directors.shard
 * ...

## HEAD -> GET
TODO: Varnish internally changes HEAD to GET before fetching, so client-sent HEAD requests trigger a GET in backends. That response is then cached, so not ever HEAD triggers a new GET.

For example, sending a `HEAD` request to `localhost:8080/path` (varnish) triggers a `GET` request to the backend with path `/path`. This response is then cached and any subsequent `GET` or `HEAD` request will be served from the cache.

## ...