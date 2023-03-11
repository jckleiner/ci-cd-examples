package com.example.varnishdemoapp;

import java.time.LocalDateTime;

import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController public class Controller {

    private static final String NODE_NUM = "1";

    @GetMapping("/") public ResponseEntity<String> getHome() {
        LocalDateTime now = LocalDateTime.now();

        System.out.println(" --> GET /  " + now);

        return ResponseEntity.ok(String.format("GET - Node %s - %s", NODE_NUM, now));
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
