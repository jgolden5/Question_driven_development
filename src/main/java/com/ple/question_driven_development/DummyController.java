package com.ple.question_driven_development;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@RestController
public class DummyController {
  @GetMapping("/")
  public String test() {
    return "Howdy partner, your Spring Boot app sure works! 🤠"
  }
}
