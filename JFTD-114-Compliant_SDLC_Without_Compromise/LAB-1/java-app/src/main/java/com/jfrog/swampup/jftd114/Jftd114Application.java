package com.jfrog.swampup.jftd114;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class Jftd114Application {
	private static final Logger LOGGER = LogManager.getLogger();
	public static void main(String[] args) {
		SpringApplication.run(Jftd114Application.class, args);
		LOGGER.deubg("SpringApplication `{}` completed successfully.", Jftd114Application.class);
	}
}
