package com.jfrog.swampup.jftd114;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class Lab3DemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(Lab3DemoApplication.class, args);
	}
	
	@GetMapping("/")
	public String hello(@RequestParam(defaultValue = "Guest") String name) {
		return "Hello %s!, Welcome to SwampUp 2025 ".formatted(name);
	}
}
