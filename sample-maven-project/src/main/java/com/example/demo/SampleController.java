package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
public class SampleController {

	@GetMapping("/")
	public String sample() {
		return "<br><h1>Spring Boot Application - Works</h1>";
	}
}
