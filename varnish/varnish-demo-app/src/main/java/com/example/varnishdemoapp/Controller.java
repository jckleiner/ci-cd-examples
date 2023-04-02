package com.example.varnishdemoapp;

import java.net.InetSocketAddress;
import java.time.LocalDateTime;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServlet;

import org.apache.commons.math3.util.MathUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.concurrent.CustomizableThreadFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import io.prometheus.client.exporter.MetricsServlet;

@RestController public class Controller {

    /**
     * Instead of creating threads, we schedule a recurring job.
     */
    private ScheduledExecutorService executor;

    private static final String NODE_NUM = "1";

    @PostConstruct public void init() {
        executor = Executors.newScheduledThreadPool(200, new CustomizableThreadFactory("mythread-"));
    }

    @GetMapping("/") public ResponseEntity<String> getHome() {
        LocalDateTime now = LocalDateTime.now();


        System.out.println(" --> GET /  " + now);

        executor.schedule(() -> {
            // takes around a minute to run
            for (int i = 0; i < 500000000; i++) {
                long fact = 1;
                for (int j = 2; j <= 210; j++) {
                    fact = fact * j;
                }
            }
            System.out.println(123);
        }, 10, TimeUnit.SECONDS);

        return ResponseEntity.ok(String.format("GET - Node %s - %s --- WORKS3", NODE_NUM, now));
    }

    @GetMapping("/health") public ResponseEntity<String> getHealth() {
        LocalDateTime now = LocalDateTime.now();

        System.out.println(" --> GET /  " + now);

        return ResponseEntity.ok(String.format("GET - Node %s - %s", NODE_NUM, now));
    }

    @GetMapping("/no-store") public ResponseEntity<String> getNoStore() {
        LocalDateTime now = LocalDateTime.now();

        System.out.println(" --> GET /no-store  " + now);

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Cache-Control", "no-store");

        return ResponseEntity.ok().headers(responseHeaders).body(String.format("GET - Node %s - %s", NODE_NUM, now));
    }

    @GetMapping("/ttl-40") public ResponseEntity<String> getCustomTTL() {
        LocalDateTime now = LocalDateTime.now();

        System.out.println(" --> GET /ttl-40  " + now);

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Cache-Control", "max-age=40");

        return ResponseEntity.ok().headers(responseHeaders).body(String.format("GET - Node %s - %s", NODE_NUM, now));
    }

    @GetMapping("/expires") public ResponseEntity<String> getExpires() {
        LocalDateTime now = LocalDateTime.now();

        System.out.println(" --> GET /expires  " + now);

        // Docs: Note: If there is a Cache-Control header with the max-age or s-maxage directive in the response, the Expires header is ignored.
        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("Expires", "Wed, 21 Oct 2015 07:28:00 GMT");

        return ResponseEntity.ok().headers(responseHeaders).body(String.format("GET - Node %s - %s", NODE_NUM, now));
    }

}
