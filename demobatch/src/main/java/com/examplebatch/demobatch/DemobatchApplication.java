package com.examplebatch.demobatch;

import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@EnableBatchProcessing 
@SpringBootApplication
public class DemobatchApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemobatchApplication.class, args);
	}

}
