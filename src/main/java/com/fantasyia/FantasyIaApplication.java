package com.fantasyia;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class FantasyIaApplication {
    public static void main(String[] args) {
        SpringApplication.run(FantasyIaApplication.class, args);
    }
}
